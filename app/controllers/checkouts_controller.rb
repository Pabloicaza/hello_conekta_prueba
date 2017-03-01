class CheckoutsController < ApplicationController


  def index
  end

  def charge
    begin

      customer = Conekta::Customer.create({
          name: "James Howlett",
          email: "james.howlett@forces.gov",
          payment_sources: [{
            token_id: "tok_test_visa_4242",
            type: "card"
          }],
          shipping_contacts: [{
            phone: "+5215555555555",
            receiver: "Marvin Fuller",
            between_streets: "Ackerman Crescent",
            address: {
              street1: "250 Alexis St",
              street2: "fake street",
              city: "Red Deer",
              state: "Alberta",
              country: "CA",
              postal_code: "T4N 0B8",
              residential: true
            }
          }]
      })

      puts params['conektaTokenId']
      puts customer.inspect

      @order = Conekta::Order.create({
        :line_items => [{
            :name => "Tacos",
            :unit_price => 1000,
            :quantity => 12
        }], #line_items
        :shipping_lines => [{
            :amount => 1500,
            :carrier => "mi compañia"
        }], #shipping_lines
        :currency => "MXN",
        :customer_info => {
            :customer_id => customer.id
        }, #customer_info
        :shipping_contact => {
            :phone => "+525555555555",
            :receiver => "Bruce Wayne",
            :address => {
                :street1 => "Calle 123 int 2 Col. Chida",
                :city => "Cuahutemoc",
                :state => "Ciudad de Mexico",
                :country => "MX",
                :postal_code => "06100",
                :residential => true
            }
        }, #shipping_contact
        :charges => [{
            :payment_method => {
                :token_id => "tok_test_visa_4242",
                :type => "card"
            } # payment_method
        }]
      })

puts @order.inspect

      puts "ID: #{@order.id}"
      puts "Status: #{@order.charges[0].status}"
      puts "$ #{(@order.amount/100).to_f} #{@order.currency}"
      puts "Order"
      puts "#{@order.line_items[0].quantity}
            - #{@order.line_items[0].name}
            - $ #{(@order.line_items[0].unit_price/100).to_f}"
      puts "Payment info"
      puts "CODE: #{@order.charges[0].payment_method.auth_code}"
      puts "Card info:
            - #{@order.charges[0].payment_method.name}
            - <strong><strong>#{@order.charges[0].payment_method.last4}
            - #{@order.charges[0].payment_method.brand}
            - #{@order.charges[0].payment_method.issuer}
            - #{@order.charges[0].payment_method.type}"



    rescue Conekta::ParameterValidationError => e
      puts e.message_to_purchaser
      #alguno de los parámetros fueron inválidos
    rescue Conekta::ProcessingError => e
      puts e.message_to_purchaser
      #la tarjeta no pudo ser procesada
    rescue Conekta::Error
      puts e.message_to_purchaser
      #un error ocurrió que no sucede en el flujo normal de cobros como por ejemplo un auth_key incorrecto
    end
  end
end
