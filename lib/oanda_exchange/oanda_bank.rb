require "money"

class OandaBank < Money::Bank::Base

  def exchange_with(from, to_currency)
    Money.new(Oanda.exchange(from.currency.to_s, :to => to_currency.to_s, :amount => from) * 
              Money::Currency.find(to_currency).subunit_to_unit, to_currency.to_s)
  end

end