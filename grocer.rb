# removes duplicates and updates item count
def consolidate_cart(cart)
    cart.each_with_object({}) do |item, new_cart|
        k, v = item.first
        if new_cart.key?(k)
            new_cart[k][:count] += 1
        else
            v[:count].nil? ? new_cart[k] = v.merge(count: 1) : new_cart[k] = v.merge(count: v[:count])
        end
    end
end

# adjust item prices after applying coupons
def apply_coupons(cart, coupons)
  return cart if coupons.count < 1
  # create a copy of cart to manipulate
  discounted_cart = cart.dup
  coupons.each do |coupon|
    key = coupon[:item]
    coupon_count = coupon[:num]
    coupon_value = coupon[:cost] / coupon[:num]
    discounted_name = "#{key} W/COUPON"
    # if coupon applies to item in cart and there are enough items to qualify
    if discounted_cart.key?(key) && discounted_cart[key][:count] >= coupon_count
      discounted_cart[key][:count] -= coupon_count
      if discounted_cart.key?(discounted_name)
        discounted_cart[discounted_name][:count] += coupon_count
      else
        discounted_cart[discounted_name] = {:price => coupon_value, :clearance => discounted_cart[key][:clearance], :count => coupon_count}
      end
    end
  end
  discounted_cart
end

# apply 20% discount to clearance items
def apply_clearance(cart)
  cart.each_with_object({}) do |item, new_cart|
    key = item.first
    item_info = item[1]
    if item_info[:clearance] == true
      item_info[:price] -= 0.2 * item_info[:price]
    end
    new_cart[key] = item_info
  end
end

# get cart total and apply 10% discount if value over 100
def total_cart(cart)
  cart_total = 0
  cart.each do |item|
    key = item.first
    item_info = item[1]
    item_info[:price] *= item_info[:count]
    cart_total += item_info[:price]
  end
  cart_total -= 0.1 * cart_total if cart_total > 100
end

# checkout cart
def checkout(cart, coupons)
  consolidated_cart = (consolidate_cart(cart))
  coupon_cart = apply_coupons(consolidated_cart, coupons)
  discount_cart = apply_clearance(coupon_cart)
  total = total_cart(discount_cart)
end
