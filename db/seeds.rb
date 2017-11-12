john = User.create(username: "johnjohn", email: "jwt@gmail.com", password: "12345")
currenttime = DateTime.now
event1 = Event.create(name: "comedy show", city: "New York", state: "NY", description: "it's a comedy show", date: "1999-05-19", time: "06:30",user_id: john.id)
event1 = Event.create(name: "comedy show", city: "New York", state: "NY", description: "it's a comedy show", date: "2018-05-19", time: "06:30",user_id: john.id)
