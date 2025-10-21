# frozen_string_literal: true
require "faker"
require "open-uri"

puts "🧹 Limpando banco..."
Comentario.destroy_all
Filme.destroy_all
Categoria.destroy_all
Tag.destroy_all
User.destroy_all

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

# === Categorias ===
puts "🏷️  Criando categorias..."
categorias = %w[Ação Drama Comédia Terror Romance Ficção Suspense Aventura Documentário]
categorias.map! { |nome| Categoria.create!(nome: nome) }

# === Tags ===
puts "🏷️  Criando tags..."
tags = %w[clássico premiado cult independente trilogia remake animação ficção mafia romance ação herói comédia terror psicológico]
tags.map! { |nome| Tag.create!(nome: nome) }

# === Filmes ===
puts "🎬 Criando filmes com pôsteres..."
users = [user1, user2]

10.times do
  file = URI.open("https://picsum.photos/seed/#{rand(1000)}/600/900")
  filme = Filme.new(
    titulo: Faker::Movie.title,
    sinopse: Faker::Lorem.paragraph(sentence_count: 5),
    ano_lancamento: rand(1980..2025),
    duracao: rand(80..180),
    diretor: Faker::Name.name,
    user: users.sample
  )

  # adiciona poster com Active Storage
  filme.poster.attach(io: file, filename: "poster_#{filme.titulo.parameterize}.jpg", content_type: "image/jpeg")

  # salva
  filme.save!

  # adiciona categorias e tags aleatórias
  filme.categorias << categorias.sample(rand(1..3))
  filme.tags << tags.sample(rand(2..4))
end

# === Comentários ===
puts "💬 Gerando comentários..."
Filme.find_each do |filme|
  rand(2..4).times do
    if [true, false].sample
      Comentario.create!(
        filme: filme,
        nome: Faker::Name.first_name,
        conteudo: Faker::Lorem.sentence(word_count: rand(6..14))
      )
    else
      user = [user1, user2].sample
      Comentario.create!(
        filme: filme,
        user: user,
        nome: user.name,
        conteudo: Faker::Lorem.sentence(word_count: rand(8..16))
      )
    end
  end
end

# === Resumo ===
puts "✅ Seeds criados com sucesso!"
puts "----------------------------------------"
puts "👤 Usuários:"
puts "  📧 #{user1.email} / 🔑 123456"
puts "  📧 #{user2.email} / 🔑 123456"
puts "🎬 Filmes criados: #{Filme.count}"
puts "🏷️  Categorias criadas: #{Categoria.count}"
puts "🏷️  Tags criadas: #{Tag.count}"
puts "💬 Comentários criados: #{Comentario.count}"
puts "----------------------------------------"
