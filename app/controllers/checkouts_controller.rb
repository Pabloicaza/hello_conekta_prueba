class CheckoutsController < ApplicationController
  def index
  end

  def charge
    begin
      @charge = Conekta::Charge.create({
        amount: params['chargeInCents'],
        currency: "MXN",
        description: "Pizza Delivery at test",
        reference_id: "001-id-test",
        details:
        {
          email: params['emailBuyer'],
          line_items: [
            { name: 'Pizza at test',
              description: 'A pizza test description',
              unit_price: params['chargeInCents'],
              quantity: 1,
              sku: 'pizza-test',
              type: 'pizza'
            }
          ]
        },
        card: params['conektaTokenId']
      })
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
