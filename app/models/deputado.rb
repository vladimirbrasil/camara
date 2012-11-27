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
#  twitter    :string(255)
#

# Afazeres
# Usar multiplas paginas simultaneas (Typhoeus)
# localizar e adicionar email
# => <Mechanize::Page::Link "dep.guilhermecampos@camara.leg.br" "mailto:dep.guilhermecampos@camara.leg.br">

class Deputado < ActiveRecord::Base
  attr_accessible :email, :facebook, :nome, :uri_id

  validates :uri_id, presence: true, uniqueness: true

  require 'nokogiri'
  require 'mechanize'
	require 'unicode'
	require 'typhoeus'
	require 'em-net-http'

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

		# hydra = Typhoeus::Hydra.new

	  # Deputado.captar_deputados
	  # i = 0
	  select_list.options.each do |value|
	  	# i = i + 1
	  	# if i > 10
				# return select_list
	  	# end
	  	nome = Unicode::capitalize(/(.*?)\|/.match(value.to_s)[1]) if /(.*?)\|/.match(value.to_s)
	  	uri_id = /\d*$/.match(value.to_s)[0].to_i if /\d*$/.match(value.to_s)

	  	@deputado = Deputado.find_by_uri_id(uri_id) || Deputado.create(uri_id: uri_id, nome: nome)

			# EM.run do
			#   Fiber.new do
	  #       self.captar_contatos_deputado(uri_id)
			#     EM.stop_event_loop
			#   end.resume
			# end


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

	  @facebook = ""
	  @twitter = ""
	  @email = ""

	  @facebook = page.link_with(:text => 'Facebook').uri.to_s if page.link_with(:text => 'Facebook')
	  # => #<Mechanize::Page::Link "Facebook" "http://www.facebook.com.br/depguilherme">
		@twitter = page.link_with(:text => 'Twitter').uri.to_s if page.link_with(:text => 'Twitter')
		# => #<Mechanize::Page::Link "Twitter" "http://www.twitter.com/depguilherme">
		@email = page.link_with(:href => /(.*)?@camara.leg.br$/).text if page.link_with(:href => /(.*)?@camara.leg.br$/)
		# => <Mechanize::Page::Link "dep.guilhermecampos@camara.leg.br" "mailto:dep.guilhermecampos@camara.leg.br">

  	@deputado = Deputado.find_by_uri_id(uri_id) || Deputado.create(uri_id: uri_id)
  	@deputado.facebook = @facebook || ""
  	@deputado.twitter = @twitter || ""
  	@deputado.email = @email || ""
  	@deputado.save

  	page

		# results = Deputado.where("twitter <> ''").select([:twitter])


	end

end
