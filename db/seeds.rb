# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Movie.create(title: "The Matrix", video_url:"SECRET")

Plan.create(name: "Small", stripe_id: "prod_JMXShtT1kmrbsD", amount: 25_00, interval: "month")
Plan.create(name: "Small", stripe_id: "prod_JMXSKqV9Rx3rkv", amount: 250_00, interval: "year")
Plan.create(name: "Large", stripe_id: "prod_JMXRqiKeRlrcAo", amount: 100_00, interval: "month")
Plan.create(name: "Large", stripe_id: "prod_JMXQwJKUj0sQDc", amount: 1000_00, interval: "year")
