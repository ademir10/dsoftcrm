# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

    User.create(
    name: 'Ademir de Góes Gomes',
    email: 'ademir@ddti.com.br',
    password: '111',
    type_access: 'MASTER',
    cuser: 'TRUE'
    )
    
    ExpireDate.create(
    date_expire: '31/12/2016',
    active: 'FALSE'
    )
