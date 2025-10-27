# Movies Felipet

Aplicação Rails 7 desenvolvida como projeto de portfólio, com funcionalidades completas de gerenciamento de filmes, categorias, tags e comentários — 
incluindo:**importação em massa via CSV**, 
          **upload de pôster com Active Storage**,
          **processamento em background com Sidekiq** e
           **preenchimento de filmes com IA**

---
## 🚀 Funcionalidades
- Cadastro e autenticação de usuários (Devise)
- IA treinada exclusivamente para preenchimento automático dos filmes.
- CRUD de filmes, categorias e comentários
- Associação de múltiplas categorias e tags a um filme
- Upload de pôster com **Active Storage**
- Importação de filmes via arquivo **CSV**
- Processamento assíncrono com **Sidekiq**
- Notificação por e-mail após importação
- Internacionalização (PT-BR / EN)
- Interface responsiva com Bootstrap e ícones do Bootstrap Icons
---

## ⚙️ Requisitos

| Ferramenta | Versão Recomendada |
|-------------|-------------------|
| Ruby | 3.0.6 |
| Rails | 7.1.5 |
| Redis | 5.0+ |
| Node.js / Yarn | Latest |
| PostgreSQL | 13.0+ |
| Amazon S3 (AWS SDK) | Armazenamento de arquivos e imagens |

Observação:
O Amazon S3 é utilizado para armazenamento de imagens e arquivos enviados pelo usuário. É necessário configurar as variáveis de ambiente AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION e AWS_BUCKET para o funcionamento correto.
---

## 💾 Instalação

# Clonar o repositório
git clone https://github.com/seu-usuario/movies_felipet.git
cd movies_felipet

# Instalar dependências
bundle install
yarn install

# Configurar banco de dados
rails db:create db:migrate db:seed

---

## 🖼️ Corrigir exibição de imagens (Pequena OBS)

O Active Storage utiliza a gem `image_processing`, que depende da biblioteca **libvips**.
CASO as imagens não aparecerem, execute:

sudo apt update
sudo apt install -f
sudo apt install libvips

---

## 🧵 Rodando o Sidekiq (configurado somete em desenv)

O Sidekiq é utilizado para processar importações CSV e envio de e-mails de forma assíncrona.

1. **Inicie o Redis**  

   sudo service redis-server start

   ou (caso o comando acima não funcione):
 
   redis-server &

2. **Rode o Sidekiq**  
   Em outro terminal, dentro do projeto:

   bundle exec sidekiq

3. **Rode o servidor Rails**

   rails s

4. Acesse a tela que usa o Sidekiq (modo desenvolvimento):

   http://localhost:3000/imports/new

## 📦 Importação CSV

O CSV deve conter as colunas:

titulo,sinopse,ano_lancamento,duracao,diretor

Exemplo de arquivo que já se econtra no projeto(filmes_exemplo.csv):

titulo,sinopse,ano_lancamento,duracao,diretor
O Senhor dos Anéis,Uma jornada épica pela Terra Média,2001,180,Peter Jackson
A Origem,Um ladrão invade sonhos para roubar segredos,2010,148,Christopher Nolan
Cidade de Deus,A ascensão do crime em uma favela carioca,2002,130,Fernando Meirelles

O upload é feito na tela de importação (`/imports/new`), e o processamento ocorre em background via Sidekiq.  
Ao final, o usuário recebe um e-mail com o resumo da importação.

## 🧩 Testes automatizados

O projeto possui testes básicos com **Minitest**, pode não funcionar:

rails test


## 🧠 Tecnologias Principais

- **Ruby on Rails 7**
- **Bootstrap 5**
- **Devise**
- **Ransack**
- **Sidekiq + Redis**
- **Action Mailer**
- **Active Storage**
- **🧠 Inteligência Artificial**

IA treinada exclusivamente para preenchimento automático dos filmes.

O sistema utiliza o modelo **GPT-4o-mini (OpenAI)** para buscar e preencher
campos como **sinopse**, **ano de lançamento**, **duração**, **diretor** e **categorias**
com base apenas no título do filme informado.

Se o título não for encontrado, o sistema solicita mais detalhes ao usuário.

## 👨‍💻 Autor

**Felipe Bernardo**  
Desenvolvedor Full Stack — Ruby on Rails  
📧 [felipe4bfonseca@gmail.com](mailto:felipe4bfonseca@gmail.com)  
🌐 [github.com/bergfelipe](https://github.com/bergfelipe)
OBS:
O sistema está hospedado no endereço https://movies-felipet.onrender.com
, utilizando o plano gratuito da plataforma Render.
Esse plano disponibiliza apenas 512 MB de memória RAM, o que, durante os testes realizados, ocasionou erros de execução recorrentes devido às limitações de recursos.
Assim, caso ocorram instabilidades, lentidão ou interrupções, ressalta-se que tais falhas decorrem exclusivamente das restrições impostas pelo ambiente gratuito do Render, e não do código-fonte ou da aplicação em si.

## 🏁 Execução resumida:
**rails db:reset              # limpa, recria e popula o banco** 

**sudo apt install libvips    # corrigir exibição de imagens**

**bundle exec sidekiq         # roda os jobs em background em desenv**

**rails s                     # inicia o servidor**



