namespace :db do
  desc 'Loads some stuff into the database for local testing'
  task(populate_test: :environment) do
    # Councils
    pryl = Council.find_or_create_by!(title: 'Prylmästeriet',
                                      url: 'pryl', description: 'Detta är Prylmästeriet')

    sexm = Council.find_or_create_by!(title: 'Sexmästeriet',
                                      url: 'sex', description: 'Detta är Sexmästeriet')
    cafem = Council.find_or_create_by!(title: 'Cafemästeriet',
                                       url: 'cafe', description: 'Detta är Cafemästeriet')
    # Posts
    # Prylmästeriet
    spindel = Post.find_or_create_by!(title: 'Spindelman', limit: 0, rec_limit: 10, description: 'En administratör',
                                      council: pryl, elected_by: Post::BOARD, semester: Post::SPRING, car_rent: true)

    prylmast = Post.find_or_create_by!(title: 'Prylmästare', limit: 1, rec_limit: 1,
                                       description: 'Prylmästarn', council: pryl, elected_by: Post::GENERAL,
                                       board: true, semester: Post::SPRING, car_rent: true)
    # Sexmästeriet

    sexmast = Post.find_or_create_by!(title: 'Sexmästare', limit: 1, rec_limit: 1,
                                      description: 'Sexmästaren', council: sexm, elected_by: Post::GENERAL,
                                      board: true, semester: Post::SPRING, car_rent: true)

    # Cafemästeriet
    Post.find_or_create_by!(title: 'Vice cafemästare', limit: 1, rec_limit: 1, description: 'En vice cm',
                            council: cafem, elected_by: Post::GENERAL,
                            board: true, semester: Post::AUTUMN, car_rent: true)

    cafemast = Post.find_or_create_by!(title: 'Cafemästare', limit: 1, rec_limit: 1,
                                       description: 'Cafemästaren', council: cafem, elected_by: Post::GENERAL,
                                       board: true, semester: Post::AUTUMN, car_rent: true)

    nyckelpiga = Post.find_or_create_by!(title: 'Nyckelpiga', limit: 0, rec_limit: 10,
                                         description: 'Nyckelpigan!', council: cafem, elected_by: Post::BOARD, semester: Post::BOTH)


    # Set president!
    pryl.update(president: prylmast)
    sexm.update(president: sexmast)
    cafem.update(president: cafemast)

    # Permissions
    Rake::Task['permissions:load'].invoke
    perm_admin = Permission.find_or_create_by!(subject_class: :all, action: :manage)
    perm_nyckelpiga = Permission.find_or_create_by!(subject_class: 'CafeWork', action: :nyckelpiga)
    # Give spindelman admin
    PermissionPost.find_or_create_by!(permission: perm_admin, post: spindel)
    PermissionPost.find_or_create_by!(permission: perm_nyckelpiga, post: nyckelpiga)

    u = User.find_or_initialize_by(email: 'admin@fsektionen.se',
                                   firstname: 'Hilbert-Admin', lastname: 'Älg',
                                   program: 'Teknisk Fysik', start_year: 1996)
    u.password = 'passpass'
    u.confirmed_at = Time.zone.now
    u.member_at = Time.zone.now
    u.save!
    puts 'You can sign in as ADMIN with'
    puts 'email:        admin@fsektionen.se'
    puts 'and password: passpass'
    if u.present?
      PostUser.find_or_create_by(post: spindel, user: u)
      PostUser.find_or_create_by(post: prylmast, user: u)
      PostUser.find_or_create_by(post: cafemast, user: u)
      PostUser.find_or_create_by(post: sexmast, user: u)
    end

    a = User.find_or_initialize_by(email: 'user@fsektionen.se',
                                   firstname: 'Hilbert', lastname: 'Älg',
                                   program: 'Teknisk Fysik', start_year: 1996)
    a.confirmed_at = Time.zone.now
    a.member_at = Time.zone.now
    a.password = 'passpass'
    a.save!

    puts 'You can sign in as USER with'
    puts 'email:        user@fsektionen.se'
    puts 'and password: passpass'
    if a.present?
      PostUser.find_or_create_by(post: prylmast, user: a)
    end

    # Menues
    menu = Menu.find_or_create_by!(location: :guild, name: 'Om oss',
                                   link: '/om', index: 10, visible: true, turbolinks: true)
    menu.update!(name_en: 'About us')

    menu = Menu.find_or_create_by!(location: :guild, name: 'Utskott',
                            link: '/utskott', index: 20, visible: true, turbolinks: true)
    menu.update!(name_en: 'Councils')

    Menu.find_or_create_by!(location: :guild, name: 'Dokument',
                            link: '/dokument', index: 30, visible: true, turbolinks: true)

    menu.update!(name_en: 'Documents')

    Menu.find_or_create_by!(location: :members, name: 'Val',
                            link: '/val', index: 10, visible: true, turbolinks: true)
    menu.update!(name_en: 'Election')

    Menu.find_or_create_by!(location: :members, name: 'Bilbokning',
                            link: '/bilbokning', index: 20, visible: true, turbolinks: false)
    menu.update!(name_en: 'Car rental')

    Menu.find_or_create_by!(location: :members, name: 'Hilbert Café',
                            link: '/hilbertcafe', index: 30, visible: true, turbolinks: false)
    menu.update!(name_en: 'Hilbert Café')

    Menu.find_or_create_by!(location: :members, name: 'Bildgalleri',
                            link: '/galleri', index: 40, visible: true, turbolinks: false)
    menu.update!(name_en: 'Image gallery')

    # Notice
    FactoryGirl.create(:notice, user: u)
    FactoryGirl.create(:notice, user: u)

    # Election
    election = Election.find_or_initialize_by(title: 'Vårterminsmöte',
                                              url: 'vt-15', visible: true )
    election.update!(start: 2.days.ago,
                     end: 5.days.from_now,
                     closing: 7.days.from_now)
    Post.all do |posten|
      election.posts << posten
    end
    election.save!

    # Contact
    Contact.find_or_create_by(name: 'Spindelman', email: 'spindelman@fsektionen.se',
                              public: true, text: 'Detta är en linte spindelman', post: spindel)

    # News
    News.find_or_create_by!(title: 'Ett helt nytt användarsystem',
                            content: 'Nu har vi en himla massa roliga funktioner som blir mycket lättare att lägga in, det är ju <br>toppen.',
                            user: User.first)
    News.find_or_create_by!(title: 'Andra helt nytt användarsystem',
                            content: 'Nu har vi en himla massa roliga funktioner som blir mycket lättare att lägga in, det är ju <br>toppen.',
                            user: User.first)
    News.find_or_create_by!(title: 'Tredje helt nytt användarsystem',
                            content: 'Nu har vi en himla massa roliga funktioner som blir mycket lättare att lägga in, det är ju <br>toppen.',
                            user: User.first)
    News.find_or_create_by!(title: 'Fjärde helt nytt användarsystem',
                            content: 'Nu har vi en himla massa roliga funktioner som blir mycket lättare att lägga in, det är ju <br>toppen.',
                            user: User.first)
    News.find_or_create_by!(title: 'Femte helt nytt användarsystem',
                            content: 'Nu har vi en himla massa roliga funktioner som blir mycket lättare att lägga in, det är ju <br>toppen.',
                            user: User.first)
    # Events
    date = Time.zone.now.middle_of_day
    (1..10).each do |i|
      event = Event.find_or_create_by!(short: %(E#{i}), title: %(Evenemang #{i}),
                                       description: 'Detta kommer bli ett evenemang!',
                                       starts_at: date, ends_at: date + 5.hours,
                                       food: true, drink: true, location: 'Gasquesalen')
      event.update!(short_en: event.short, title_en: %(Event #{i}), description_en: 'This will be an event!')
      date = date + 1.days + [-3,-2,-1,0,1,2,3].sample.hours
    end

    # Gallery
    Album.find_or_create_by!(title: 'Välkomstgasque', description: 'Väldans trevligt!', location: 'Gasquesalen',
                             start_date: Time.zone.now, category: 'Nollning', end_date: Time.zone.now + 10.hours)

    # Documents
    FactoryGirl.create(:document)
    FactoryGirl.create(:document)

    # Categories
    Category.find_or_create_by!(title: 'Studier', slug: 'studie')
    Category.find_or_create_by!(title: 'Sektionen', slug: 'sektion')
    Category.find_or_create_by!(title: 'Fritid', slug: 'fritid')

    #Tool
    tool = Tool.find_or_create_by!(title: 'Hammare', description: 'spikar spikar m.m.', total: 5)
    #Tool Renting
    ToolRenting.find_or_create_by!(renter: 'adrian', tool: tool, purpose: 'for home use', return_date: Time.zone.now)
    ToolRenting.find_or_create_by!(renter: 'adrian2', tool: tool, purpose: 'for other use', return_date: Time.zone.now)
  end
end
