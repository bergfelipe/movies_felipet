# frozen_string_literal: true
require "faker"
require "open-uri"

puts "🧹 Limpando banco..."


# === Usuários ===
puts "👤 Criando usuários..."
user1 = User.create!(
  name: "Felipe Fonseca",
  email: "felipe4bfonseca@gmail.com",
  password: "123456",
  password_confirmation: "123456"
)

user2 = User.create!(
  name: "Carla Andrade",
  email: "carla@example.com",
  password: "123456",
  password_confirmation: "123456"
)

puts "----------------------------------------"
puts "👤 Usuários:"

puts "----------------------------------------"
