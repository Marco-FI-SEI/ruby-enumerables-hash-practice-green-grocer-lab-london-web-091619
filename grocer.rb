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

def consolidate_coupons(coupons)
  coupons.group_by { |obj| obj[:item] }.map do |key, value|
    num_sum = value.sum { |i| i[:num] }
    cost_sum = value.sum { |i| i[:cost] }
    Hash[:item, key, :num, num_sum, :cost, cost_sum]
  end
end

def apply_coupons(cart, coupons)
  return cart if coupons.count < 1
  discounted_cart = {}
  cons_coupons = consolidate_coupons(coupons)
  cart.each_key do |key|
    discounted_cart[key] = cart.delete(key) if !cons_coupons.find { |coupon| coupon[:item] == key}
    cons_coupons.each do |coupon|
      if key == coupon[:item]
        discounted_name = "#{key} W/COUPON"
        coupon_value = coupon[:cost] / coupon[:num]
        if coupon[:num] >= cart[key][:count]
          discounted_cart[discounted_name] = {:price => coupon_value, :clearance => cart[key][:clearance], :count => cart[key][:count]}
          cart[key][:count] = 0
          discounted_cart[key] = cart[key]
        elsif coupon[:num] < cart[key][:count]
          discounted_cart[discounted_name] = {:price => coupon_value, :clearance => cart[key][:clearance], :count => coupon[:num]}
          cart[key][:count] -= coupon[:num]
          discounted_cart[key] = cart[key]
        end
      end
    end
  end
  discounted_cart
end

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

def total_cart(cart)
  cart_total = 0
  cart.each do |item|
    key = item.first
    item_info = item[1]
    item_info[:price] *= item_info[:count]
    cart_total += item_info[:price]
  end
  cart_total -= 0.1 * cart_total if cart_total > 100
  cart_total
end

def checkout(cart, coupons)
  consolidated_cart = (consolidate_cart(cart))
  coupon_cart = apply_coupons(consolidated_cart, coupons)
  discount_cart = apply_clearance(coupon_cart)
  total = total_cart(discount_cart)
end
