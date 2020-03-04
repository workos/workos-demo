# IdP Link

WorkOS offers a Javascript based embeddable widget that allows your Enterprise users to configure their Single Sign-On Identity Provider themselves. Using IdP Link allows you to reduce the back and forth between your team and your new Enterprise customer, getting the Enterprise onboarded quicker and using your application.

![alt text](./IdPLink.gif)


### Configuring Identity Providers for WorkOS SSO

Whenever you need to onboard a new Enterprise, you'll need to exchange some information with the Enterprise to set up their SSO Identity Provider. You'll create a secure handshake between your application and the Enterprise's Identity Provider via WorkOS.

First, WorkOS will generate and you'll provide an Enterprise with an Assertion Consumer Service (ACS) URL. This tells the IdP where to redirect the Enterprise user with an authentication response when they wish to sign in to your app. WorkOS provides this value to you, and you must provide it to the Enterprise.

Next, the Enterprise must create and configure your application in their Identity Provider. They'll use the ACS URL you provide, as well as some other pieces of information specific to the provider that WorkOS will also provide as needed.

Once complete, the Enterprise will have all of the information needed to finish configuring the IdP via WorkOS. The Enterprise can relay this information to your team, who can then use that information to complete the IdP configuration on the WorkOS dashboard.

Instead, this repository demonstrates how to use WorkOS IdP Link to allow the Enterprise to enter this information themselves.

### Installation

WorkOS IdP Link is available as a Javascript embed via the WorkOS CDN. WorkOS is always adding new Identity Providers and keeping the embed updated, so it's important you include the script from the WorkOS CDN as opposed to copying it into your codebase. Include the following script tag on your website:

```html
<script async type="text/javascript" src="https://cdn.workos.com/idp-link.min.js"</script>

```

Then add an element to your DOM with the class `workos-container`

```html
<div 
  class='workos-container'
  data-prop-domain='CURRENT-USER-DOMAIN'
  data-prop-name='CURRENT-USER-COMPANY-NAME'
  data-prop-project-id='WORKOS_PROJECT_ID'
  data-prop-publishable-key='WORKOS_PUBLISHABLE_KEY'
/>
```

When the IdP Link loads and executes, this element will be replaced by a Button that launches a modal for configuring an Identity Provider.

### Data props

Pass information into WorkOS IdP Link with _data attributes_. The attributes must be kebab-cased.

| Attribute                 | Required? | Value                                                    |
|---------------------------|-----------|----------------------------------------------------------|
| data-prop-project-id      | true      | Your Project ID from the [WorkOS Dashboard](https://dashboard.workos.com/sso/configuration)                |
| data-prop-publishable-key | true      | Your Publishable Key from the [WorkOS Dashboard](https://dashboard.workos.com/api-keys)           |
| data-prop-domain          | true      | The primary domain for the current Enterprise account    |
| data-prop-name            | true      | An identifier string for the Enterprise account          |
| data-prop-app-name        | true      | The name of your application for display within IdP Link |

### IdP Link Confirmations

Calls made to the WorkOS API via IdP Link use your Publishable Key. The Publishable Key security model allows you to expose this key on the frontend of your application. But we don't want just _anyone_ to be able to configure SSO for your application should the key be leaked to a bad actor.

In order to keep your application secure, while making IdP Configuration easy for you and the Enterprise, **actions taken from inside IdP Link must be confirmed with a server-side API call**.

IdP Link will dispatch a custom event to the parent window when an Enterprise configures an IdP. This event `'workos:providerLinked'` will include a `token` that you must pass to your back end. Subscribe to this event, and pass the token to your API.

```html
<script type='text/javascript'>
  document.addEventListener('workos:providerLinked', function (event){
    var xhr = new XMLHttpRequest();
    xhr.open("POST", '/confirm', true);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.send("token=" + event.detail.token);
  })
</script>
```

Finally, using one of the WorkOS SDK's, confirm the pending IdP configuration with a server-side API call authenticated with your Secret Key:

```ruby
post '/confirm' do
  WorkOS::SSO.promote_draft_connection(
    token: params['token'],
  )
end
```

See the relevant documentation in our (Node)[https://github.com/workos-inc/workos-node], (Go)[https://github.com/workos-inc/workos-go], (Python)[https://github.com/workos-inc/workos-python] or (Ruby)[https://github.com/workos-inc/workos-ruby] SDK.

### Try it Yourself

Ready to play with IdP Link to see how it works? Go ahead and deploy a version of this Demo App to Heroku. You'll need your Project ID, Publishable Key and Secret Key from the WorkOS Dashboard.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

In order to test SSO sign-ons for Identity Providers configured through IdP Link, you'll need an account with an IdP. Get in touch with WorkOS, we're happy to provision you an account in our `foo-corp.com` Okta instance, and can walk through a full implentation with you.

[![Book Time](./book-time.png)](https://calendly.com/workos-taylor/sso-onboarding)
