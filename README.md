# **LINE BOT Using Ruby on Rails**

Try to create bot LINE using Ruby on Rails
Feel free to use

## What I use
* Ruby 2.5.3
* Rails 5.2.2
* PostgreSQL

## How to use
1. Clone this repo

    ```
    git clone https://github.com/lulu8879/cecelinebot.git
    ```
    
2. Create heroku app on [Heroku](https://heroku.com/) or use Heroku CLI

    ```
    heroku create your-app-name
    ```

3. Add `LINE_CHANNEL_SECRET` and `LINE_CHANNEL_TOKEN` on Heroku Dashboard/Settings/Config Vars or use Heroku CLI, u can get them from [LINE Developers](https://developers.line.biz/console/)

    ```
    heroku config:set LINE_CHANNEL_SECRET=your_secret
    
    heroku config:set LINE_CHANNEL_TOKEN=your_token
    ```

4. Push to heroku

    ```
    git push heroku master
    ```
    
5. Migrate DB

    ```
    heroku run rails db:create && heroku run rails db:migrate
    ```

6. Fill Webhook URL on [LINE Developers](https://developers.line.biz/console/)
    
    `https://your-app-name.herokuapp.com/callback`

7. Test it
    
    ![Example Test]()

## Source
* https://github.com/line/line-bot-sdk-ruby
