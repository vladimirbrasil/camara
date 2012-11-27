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

require 'spec_helper'

describe Deputado do
  before do 
    @deputado = Deputado.new(nome: "Example Deputado", 
    						email: "dep.exemplo@camara.leg.br", 
  							facebook: "http://www.facebook.com.br/facebook_deputado",
  							uri_id: 528487
  							)
  end

  subject { @deputado }

  it { should respond_to(:nome) }
  it { should respond_to(:email) }
  it { should respond_to(:facebook) }
  it { should respond_to(:uri_id) }

end

# http://www.camara.gov.br/Internet/deputado/Dep_Detalhe.asp?id=528487
