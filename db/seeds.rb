john = User.create(username: "johnjohn", email: "jwt@gmail.com", password: "12345")
currenttime = DateTime.now
event1 = Event.create(name: "comedy show", city: "New York", state: "NY", description: "it's a comedy show", time_of_event: currenttime, user_id: john.id)
