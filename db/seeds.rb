# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Article.create([
                 { title: 'Article 1', content: 'Content 1', slug: 'slug-1' },
                 { title: 'Article 2', content: 'Content 2', slug: 'slug-2' },
                 { title: 'Article 3', content: 'Content 3', slug: 'slug-3' },
                 { title: 'Article 4', content: 'Content 4', slug: 'slug-4' }
               ])
