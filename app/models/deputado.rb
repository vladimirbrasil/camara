# == Schema Information
#
# Table name: deputados
#
#  id         :integer          not null, primary key
#  nome       :string(255)
#  email      :string(255)
#  facebook   :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  uri_id     :integer
#

class Deputado < ActiveRecord::Base
  attr_accessible :email, :facebook, :nome, :uri_id

  validates :uri_id, presence: true, uniqueness: true

  require 'nokogiri'
  require 'mechanize'

  def self.iniciar_sessao
  	if @agent.nil?
		  @agent = Mechanize.new
		  @agent.user_agent_alias = 'Windows Mozilla'
		  @agent.follow_meta_refresh = true
		  @agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE  
		end
	end

	def self.captar_deputados
		iniciar_sessao
	  url = "http://www2.camara.leg.br/deputados/pesquisa"

	  # page = @agent.get("#{url}&pagina=#{pagina}")
	  page = @agent.get("#{url}")

	  form = page.form_with(id: 'formDepAtual')
	  select_list = form.field_with(:id => "deputado")
	  
	  select_list

	  # Deputado.captar_deputados
	  select_list.options.each do |value|
	  	nome = /(.*?)\|/.match(value.to_s)[1].titlecase if /(.*?)\|/.match(value.to_s)
	  	uri_id = /\d*$/.match(value.to_s)[0].to_i if /\d*$/.match(value.to_s)

	  	@deputado = Deputado.find_by_uri_id(uri_id) || Deputado.create(uri_id: uri_id, nome: nome)

	  	self.captar_contatos_deputado(uri_id)
	  end

	  select_list

	  # node = Nokogiri::HTML(page.body)
	end

	def self.captar_contatos_deputado(uri_id)
	  # Deputado.captar_contatos_deputado
		iniciar_sessao

		url_dep = "http://www.camara.gov.br/internet/Deputado/dep_Detalhe.asp?id=#{uri_id}"

	  page = @agent.get("#{url_dep}")

	  @facebook = page.link_with(:text => 'Facebook').uri.to_s if page.link_with(:text => 'Facebook')
	  # => #<Mechanize::Page::Link "Facebook" "http://www.facebook.com.br/depguilherme">
		@twitter = page.link_with(:text => 'Twitter').uri.to_s if page.link_with(:text => 'Twitter')
		# => #<Mechanize::Page::Link "Twitter" "http://www.twitter.com/depguilherme">

  	@deputado = Deputado.find_by_uri_id(uri_id) || Deputado.create(uri_id: uri_id)
  	@deputado.facebook = @facebook if @facebook
  	@deputado.save if @facebbok or @twitter

  	page
		# => <Mechanize::Page::Link "dep.guilhermecampos@camara.leg.br" "mailto:dep.guilhermecampos@camara.leg.br">




	end

end
