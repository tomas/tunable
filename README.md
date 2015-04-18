Tunable
=======

A simple gem that provides scoped, pluggable settings for your AR 4+ models. Let's you keep things simple in your models by moving all customizable settings into a separate table, using a polymorphic Settings model. 

The code
--------

``` rb
class User < ActiveRecord::Base
  include Tunable::Model
end
```

Now we can do:

``` rb
  user = User.create(:name => 'John Lennon')
  user.get_setting(:theme, :layout) # => nil
  user.get_setting(:theme, :color) # => nil

  user.settings = { theme: { format: 'wide', color: 'red' } }
  user.save

  user.get_setting(:theme, :layout) # => 'wide'
  user.get_setting(:theme, :color) # => 'red'
```

You can also get a flat hash of your settings by calling the `settings_hash` method.

``` rb
  user.settings_hash # => { :theme => { :layout => 'wide', :color => 'red' } }
```

Tunable also lets you set defaults for your settings. Let's set up default notification settings for our Users. 

``` rb
class User < ActiveRecord::Base
  include Tunable::Model

  has_settings :notify => {
    activity:      false,
    new_messages:  true,
    weekly_report: false
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

Tunable also provides a `main_settings` helper that sets up main level settings. These automatically define setters and getters for your model instances.

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

Beautiful. You can also set a lambda to return the default setting for a model.


``` rb
class User < ActiveRecord::Base
  include Tunable::Model

  main_settings :layout_type => {
    :default => lambda { |user| user.is_admin? ? 'advanced' : 'simple' }
  }

end
```

Then:

``` rb
  user = User.create(:name => 'Ringo Starr', :admin => false)
  user.layout_type # => 'simple'
  user.admin = true
  user.layout_type # => 'advanced'
```

That's pretty much it. Fork away and send a PR, but please add tests for it.

Boring stuff
------------

Copyright (c) Fork Ltd. (http://forkhq.com), released under the MIT license.
