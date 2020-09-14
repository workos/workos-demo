# WorkOS Admin Portal Demo

An example Sinatra app demonstrating how onboarding an enterprise may work utilizing the Admin Portal.

### Installation

To utilize the Admin Portal you'll first need to create an Organization for the enterprise.

```ruby
require 'workos'

WorkOS.key = 'YOUR_SECRET_KEY'

organization = WorkOS::Portal.create_organization(
  domains: ["enterprise.com"],
  name: 'Enterprise',
)
```

You can now use the created Organization to generate a secure URL for the enterprise to access the Admin Portal.

```ruby
portal_link = WorkOS::Portal.generate_link(
  intent: 'sso',
  organization: organization.id
)

redirect portal_link
```

### Try it Yourself

Ready to test out the Admin Portal for yourself? Go ahead and deploy a version of this Demo App to Heroku. You'll need your Project ID, Publishable Key and Secret Key from the WorkOS Dashboard.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

In order to test SSO sign-ons for Identity Providers configured through the Admin Portal, you'll need an account with an IdP. Get in touch with WorkOS, we're happy to provision you an account in our `foo-corp.com` Okta instance, and can walk through a full implentation with you.

[![Book Time](./book-time.png)](https://calendly.com/workos-scheduling/demo)
