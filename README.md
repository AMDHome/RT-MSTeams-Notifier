# RT-MSTeams-Notifier
This is a tool to send MS Teams notifications for new tickets in request tracker (Tested on RT5)).

It can be easily modified to include all updates, but the instructions below are just for new tickets.

The notification will end up looking like this:
![image](https://github.com/user-attachments/assets/971ee473-90b5-4aea-86f1-fa9b0d20236f)

Clicking the purple-ish text will take you to the ticket directly in your web browser.  
Clicking on the `View in RT` will do the same thing.

The `Show Content` button will give you the initial email/message that was inputted when the ticket was created.

## Setup
This is how to set it up for just new tickets.

1. Open up MS Teams in the web browser and create a webhook url in the channel you want to use.
   - [CLICK HERE for instructions on how to do that from Microsoft](https://learn.microsoft.com/en-us/microsoftteams/platform/webhooks-and-connectors/how-to/add-incoming-webhook?tabs=newteams%2Cdotnet#create-an-incoming-webhook)
   - As of writing this README, you can't seem create webhooks in the app. It must be done through the web version
3. Log into RT and go to **Admin** > **Scrips** > **Create**
4. Fill out the basics
   - Description: Give the scrip a name
   - Condition: **On Create**
   - Action: **User Defined**
   - Template: **Blank**
   - Stage: **Normal**
5. Fill out `User defined conditions and results`
   - Custom Condition: `return 1;`
   - Custom action preparation code: `return 1;`
   - Custom action commit code: Copy and paste the code from `scrip.pl` in this repo
6. Customize the script
   - Change `$webhook_url` to the webhook URL you got in step 1
   - Change `$rt_domain` to your RT's domain. It should include everything before `/Ticket` when you open up a ticket in your instance.  
     IE. If the URL for a ticket is `https://example.com/rt/Ticket/Display.html?id=19287`  
     Then your `$rt_domain` is `https://example.com/rt`

Save everything and test it out. 

You should be able to get notifications for when new tickets show up.
