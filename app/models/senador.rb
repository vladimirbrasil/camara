class Senador < ActiveRecord::Base
  attr_accessible :email, :facebook, :nome, :twitter, :uri_id

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
		@agent
	end

	def self.captar_senadors
		iniciar_sessao
	  url = "http://www.senado.gov.br/"

	  # page = @agent.get("#{url}&pagina=#{pagina}")
	  page = @agent.get("#{url}")

	  form = page.form_with(id: 'formSenadores1')
	  select_list = form.field_with(:id => "listaSenadoresEmExercicioSgls")
	  
	  select_list

		# hydra = Typhoeus::Hydra.new

	  # Senador.captar_senadors
	  # i = 0
	  select_list.options.each do |item|
	  	# i = i + 1
	  	# if i > 10
				# return select_list
	  	# end
	  	if /(.*?) \(/.match(item.text.to_s)
		  	nome = Unicode::capitalize(/(.*?) \(/.match(item.text.to_s)[1]) 
		  	uri_id = item.value.to_i if item.value

	  		@senador = Senador.find_by_uri_id(uri_id) || Senador.create(uri_id: uri_id, nome: nome)

		  	self.captar_contatos_senador(uri_id)
		  end

	  end

	  select_list

	  # node = Nokogiri::HTML(page.body)
	end

	def self.captar_contatos_senador(uri_id)
	  # Senador.captar_contatos_senador
		iniciar_sessao

		url_dep = "http://www.senado.gov.br/senadores/dinamico/paginst/senador#{uri_id}a.asp"

	  page = @agent.get("#{url_dep}")

	  @facebook = ""
	  @twitter = ""
	  @email = ""

	  # @facebook = page.link_with(:text => 'Facebook').uri.to_s if page.link_with(:text => 'Facebook')
	  # => #<Mechanize::Page::Link "Facebook" "http://www.facebook.com.br/depguilherme">
		# @twitter = page.link_with(:text => 'Twitter').uri.to_s if page.link_with(:text => 'Twitter')
		# => #<Mechanize::Page::Link "Twitter" "http://www.twitter.com/depguilherme">
		@email = page.link_with(:href => /.*?@senado.*?\.gov\.br$/).text if page.link_with(:href => /.*?@senado.*?\.gov\.br$/)
		# => <Mechanize::Page::Link "dep.guilhermecampos@camara.leg.br" "mailto:dep.guilhermecampos@camara.leg.br">

  	@senador = Senador.find_by_uri_id(uri_id) || Senador.create(uri_id: uri_id)
  	@senador.facebook = @facebook || ""
  	@senador.twitter = @twitter || ""
  	@senador.email = @email || ""
  	@senador.save

  	page

		# results = Senador.where("twitter <> ''").select([:twitter])


	end
end
