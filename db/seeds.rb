# frozen_string_literal: true
require "faker"

puts "🧹 Limpando banco..."
Comentario.destroy_all
Filme.destroy_all
User.destroy_all

puts "👤 Criando usuário padrão..."
user = User.create!(
  name: "Felipe Fonseca",
  email: "felipe4bfonseca@gmail.com",
  password: "123456",
  password_confirmation: "123456"
)

puts "🎬 Criando filmes..."
filmes = []
6.times do
  filme = Filme.create!(
   titulo: Faker::Movie.title,
    sinopse: Faker::Lorem.paragraph(sentence_count: 5),
    ano_lancamento: rand(1980..2025),
    duracao: rand(80..180),
    diretor: Faker::Name.name,
    imagem_url: "https://picsum.photos/seed/#{rand(1000)}/640/480",
    user: user
  )
  filmes << filme
end

puts "💬 Gerando comentários..."
filmes.each do |filme|
  rand(2..4).times do
   if [true, false].sample
  # Anônimo
  Comentario.create!(
    filme: filme,
    nome: Faker::Name.first_name,
    conteudo: Faker::Lorem.sentence(word_count: rand(6..14))
  )
else
  # Logado
  Comentario.create!(
    filme: filme,
    user: user,
    nome: user.name,
    conteudo: Faker::Lorem.sentence(word_count: rand(8..16))
  )
end

  end
end

puts "✅ Seeds criados com sucesso!"
puts "Usuário padrão:"
puts "📧  Email: #{user.email}"
puts "🔑  Senha: 123456"
puts "🎬  Filmes criados: #{Filme.count}"
puts "💬  Comentários criados: #{Comentario.count}"
