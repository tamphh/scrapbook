### Ruby code
```ruby
# http://rubyblog.pro/2017/11/chain-of-responsibility-ruby

class Customer
  attr_reader :number_of_orders

  def initialize(number_of_orders)
    @number_of_orders = number_of_orders
  end
end

class BaseDiscount
  attr_reader :successor

  def initialize(successor = nil)
    @successor = successor
  end

  def next_handler(successor)
  	@successor = successor
  	successor
  end

  def call(customer)
    return successor.call(customer) unless applicable?(customer)

    puts "#{self.class.name} : #{discount}"
    discount
  end
end

class BlackFridayDiscount < BaseDiscount

  private

  def discount
    0.3
  end


  def applicable?(customer)
    false
  end
end

class LoyalCustomerDiscount < BaseDiscount

  private

  def discount
    0.1
  end

  def applicable?(customer)
    customer.number_of_orders > 5
  end
end

class DefaultDiscount < BaseDiscount

  private

  def discount
    0.05
  end

  def applicable?(customer)
    true
  end
end

chain = BlackFridayDiscount.new(LoyalCustomerDiscount.new(DefaultDiscount.new))
bfd.call(Customer.new(6))

# or (recommended)

bfd = BlackFridayDiscount.new
bfd.next_handler(LoyalCustomerDiscount.new).next_handler(DefaultDiscount.new)
bfd.call(Customer.new(6))
```

### Ref
- https://naturaily.com/blog/chain-of-responsibility-ruby-on-rails
- https://refactoring.guru/design-patterns/chain-of-responsibility/ruby/example
- http://rubyblog.pro/2017/11/chain-of-responsibility-ruby
- https://medium.com/kkempin/chain-of-responsibility-design-pattern-in-ruby-e0b756d4bb3b
