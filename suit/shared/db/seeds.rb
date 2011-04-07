# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

AuthlogicUser.create :email => "paul.engel@holder.nl", :crypted_password => "86435d9f6e85403d20881122b001e9fd5822325e74f24e162a2e51ab64ff92f15d024a3c37a494e987ed7c3666d2754fbf9673262125f4b3c1e5cf101b88569b", :password_salt => "bGryHxjIwmTxF45JyoBE"
DeviseUser   .create :email => "paul.engel@holder.nl", :password => "testrichcms"