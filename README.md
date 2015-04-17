Tunable
=======

Pluggable settings for your AR models.

The code
--------

Let's set up notification settings for our Users.

``` rb
class User < ActiveRecord::Base
  include Tunable::Model

  has_settings :notify => :activity, :new_messages, :weekly_report
end
```

Now we can do:

``` rb
  user = User.create(:name => 'John Lennon')
  user.get_setting(:notify, :activity) # => nil

  user.settings = { notify: { activity: true } }
  user.save

  user.get_setting(:notify, :activity) # => true
```

Tunable also lets you set defaults for your settings. Here's how.


``` rb
class User < ActiveRecord::Base
  include Tunable::Model

  has_settings :notify => {
    activity:      { default: false },
    new_messages:  { default: true },
    weekly_report: { default: true }
  }
end
```

Now we can do:

``` rb
  user = User.create(:name => 'John Lennon')
  user.get_setting(:notify, :new_messages) # => true (default value)

  user.settings = { notify: { new_messages: false } }
  user.save

  user.get_setting(:notify, :new_messages) # => false
```

Tunable also provides a `main_settings` helper that sets up main level settings.

``` rb
class User < ActiveRecord::Base
  include Tunable::Model

  # in this case we're not setting a default value for the :no_cookies setting
  main_settings :no_cookies, :language => { :default => 'en' }
end
```

Now let's see what happens.


``` rb
  user = User.create(:name => 'Paul MacCartney')
  user.no_cookies # => nil
  user.language # => 'en'

  user.language = 'es'
  user.no_cookies = true
  user.save

  user.no_cookies # => true
  user.language # => 'es'
```

You can also set a lambda to return the default setting for a model.


``` rb
class User < ActiveRecord::Base
  include Tunable::Model

  main_settings :layout_color => {
    :default => lambda { |user| user.is_admin? ? 'black' : 'blue' }
  }

end
```

Then:

``` rb
  user = User.create(:name => 'Ringo Starr', :admin => false)
  user.layout_color # => 'blue'
  user.admin = true
  user.layout_color # => 'black'
```

That's pretty much it. Fork away and send a PR, but please add tests for it.

Boring stuff
------------

Copyright (c) Fork Ltd. (http://forkhq.com), released under the MIT license.
