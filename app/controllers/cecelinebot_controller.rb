require 'line/bot'

class CecelinebotController < ApplicationController
  protect_from_forgery except: :callback

  def client
    @client ||= Line::Bot::Client.new do |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    end
  end

  def reply_text(event, texts)
    texts = [texts] if texts.is_a?(String)
    client.reply_message(
      event['replyToken'],
      texts.map { |text| {type: 'text', text: text} }
    )
  end

  def reply_content(event, messages)
    res = client.reply_message(
      event['replyToken'],
      messages
    )
    puts res.read_body if res.code != 200
  end

  def callback
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    head :bad_request unless client.validate_signature(body, signature)

    events = client.parse_events_from(body)
    events.each do |event|
      case event
      when Line::Bot::Event::Postback
        handle_postback(event)

      when Line::Bot::Event::Message
        handle_message(event)

      when Line::Bot::Event::Join
        reply_text(event, 'Thx udah di invite ke sini! Ho ho ho~')

      when Line::Bot::Event::Follow
        reply_text(event, 'Thx udah follow OA ini!')

      end
    end
    head :ok
  end

  def handle_postback(event)
    case event['postback']['data'].downcase
    when 'materi sem 1', 'materi sem 4', 'materi sem 5', 'materi sem 6', 'materi sem 7'
      msg = 'Still in progress~'
      reply_text(event, msg)

    end
  end

  def handle_message(event)
    case event.type
    when Line::Bot::Event::MessageType::Text
      event_msg = event.message['text'].downcase
      case event_msg
      when 'roll'
        roll = rand(0..100)
        hasil = if roll == 100
                  'Etto..., Omedetou gozaimasu! ^_^'
                elsif roll > 80
                  'You are so lucky!'
                elsif roll > 50
                  'Nani?!, you almost lucky today!'
                elsif roll > 30
                  'Ahhhhh, you are unlucky!'
                else
                  'Anone anone, you have a worst day today!'
                end
        reply_text(event, "You got #{roll}%\n#{hasil}")

      when 'profile'
        profile = client.get_profile(event['source']['userId'])
        profile = JSON.parse(profile.read_body)

        msg = "Display Name : #{profile['displayName']}"
        msg += "\nStatus Message : #{profile['statusMessage']}"
        msg += "\nUser Id : #{profile['userId']}"
        msg += "\nPicture : #{profile['pictureUrl']}"

        reply_content(event, [
                        {
                          type: 'text',
                          text: msg
                        },
                        {
                          type: 'image',
                          originalContentUrl: profile['pictureUrl'].to_s,
                          previewImageUrl: profile['pictureUrl'].to_s
                        }
                      ])

      when '/help'
        help = 'List Commands : '
        help += "\nquote = random quote"
        help += "\nroll = test ur luck"
        help += "\ntext/teks 'kalimat' = tulisan jd image"
        help += "\nchoose pilihan1 | pilihan2 = milih antara pilihan1 atau pilihan 2"
        help += "\nprofile = check profile line mu"
        help += "\n/kuliah = info kuliah"
        help += "\n/dosen = list kontak dosen"
        help += "\n/help = list command"
        help += "\n/materisem2 = list materi sem 2"
        help += "\n/materisem3 = list materi sem 3"
        reply_text(event, help)

      when '@bye'
        case event['source']['type']
        when 'group'
          reply_text(event, "Ie Damme Dayo onii-chan :'(\nOK, Bye!\nLeaving Group~~")
          client.leave_group(event['source']['groupId'])

        when 'room'
          reply_text(event, "Ie Damme Dayo onii-chan :'(\nOK, Bye!\nLeaving Room~~")
          client.leave_room(event['source']['roomId'])

        end

      when '/materisem2'
        msg = '1. Olahraga : http://bit.ly/2EwxQ86'
        msg += "\n\n2. Statistika : http://bit.ly/2Ev0C9d"
        msg += "\n\n3. Wimaya : http://bit.ly/2IDE6gM"
        msg += "\n\n4. JarKom : http://bit.ly/2Hkp1Bm"
        msg += "\n\n5. Algo : http://bit.ly/2GLQTNI"
        msg += "\n\n6. KoMas : http://bit.ly/2EvETOj"
        msg += "\n\n7. PKn : http://bit.ly/2GMWOBY"
        reply_text(event, msg)

      when '/materisem3'
        msg = '1. Struktur Data : http://bit.ly/2wfFstE'
        msg += "\n\n2. PBO : http://bit.ly/2LemGrM"
        msg += "\n\n3. Otomata dan PK : http://bit.ly/2Bxzuu0"
        msg += "\n\n4. Matriks dan Ruang Vektor : http://bit.ly/2MtgqSI"
        msg += "\n\n5. Riset Operasi : http://bit.ly/2DSQjR4"
        msg += "\n\n6. SO : http://bit.ly/2P6PTbb"
        msg += "\n\n7. STI : http://bit.ly/2IAabYa"
        msg += "\n\n8. KoNum : http://bit.ly/2IAZVyK"
        reply_text(event, msg)

      when '/dosen', '/kontak', 'contact'
        img = 'https://res.cloudinary.com/lulu8879/image/upload/v1544798426/9007158634518.jpg'
        msg = {
          type: 'image',
          originalContentUrl: img.to_s,
          previewImageUrl: img.to_s
        }
        reply_content(event, msg)

      when '/kalender'
        img = 'https://res.cloudinary.com/lulu8879/image/upload/v1544797763/9007158213959.jpg'
        msg = {
            type: 'image',
            originalContentUrl: img.to_s,
            previewImageUrl: img.to_s
        }
        reply_content(event, msg)

      when 'quote'
        uri = URI('http://quotesondesign.com/wp-json/posts?filter[orderby]=rand&filter[posts_per_page]=1')
        getquote = JSON.parse(Net::HTTP.get(uri))
        quote = getquote[0]['content']
        quote = quote[3..(quote.index('.'))]
        author = getquote[0]['title']
        msg = "\"#{quote}\" \n-#{author}"
        reply_text(event, msg)

      when '/kuliah'
        reply_content(event,
                      type: 'template',
                      altText: 'Menu Kuliah',
                      template: {
                        type: 'buttons',
                        thumbnailImageUrl: 'https://via.placeholder.com/1024/000000/FFFFFF/?text=Info+Kuliah',
                        title: 'Info Kuliah',
                        text: 'Seputar dosen, materi, kalender akademik, dll',
                        actions: [
                          { label: 'Kalender Akademik', type: 'message', text: '/kalender' },
                          { label: 'Kontak Dosen', type: 'message', text: '/dosen' },
                          { label: 'Materi Kuliah', type: 'message', text: '/materi' },
                          { label: 'Give me a quote!', type: 'message', text: 'quote' }
                        ]
                      })

      when '/materi'
        reply_content(event,
                      type: 'template',
                      altText: 'List Materi',
                      template: {
                        type: 'carousel',
                        columns: [
                          {
                            title: 'Page 1',
                            text: 'Materi Semester I, II, III',
                            actions: [
                              { label: 'Materi Sem I', type: 'postback', data: 'materi sem 1' },
                              { label: 'Materi Sem II', type: 'message', text: '/materisem2' },
                              { label: 'Materi Sem III', type: 'message', text: '/materisem3' }
                            ]
                          },
                          {
                            title: 'Page 2',
                            text: 'Materi Semester IV, V, VI',
                            actions: [
                              { label: 'Materi Sem IV', type: 'postback', data: 'materi sem 4' },
                              { label: 'Materi Sem V', type: 'postback', data: 'materi sem 5' },
                              { label: 'Materi Sem VI', type: 'postback', data: 'materi sem 6' }
                            ]
                          },
                          {
                            title: 'Page 3',
                            text: 'Materi Semester VII, VIII, IX',
                            actions: [
                              { label: 'Materi Sem VII', type: 'postback', data: 'materi sem 7' },
                              { label: 'Materi Sem VIII', type: 'postback', data: 'materi sem 8' },
                              { label: 'Materi Sem IX', type: 'postback', data: 'materi sem 9' }
                            ]
                          }
                        ]
                      })

      else
        case event_msg.split(' ').first
        when 'apakah'
          answer = rand(0..1)
          result = answer.odd? ? 'Ya' : 'Tidak'
          reply_text(event, result.to_s)

        when 'choose'
          choose = event_msg.split('choose ')[1].split('|')
          hasil1 = rand(0..100)
          hasil2 = 100 - hasil1
          better = (hasil1 > hasil2) ? choose[0] : choose[1]
          msg = "Result : \n#{hasil1}% #{choose[0]}\n#{hasil2}% #{choose[1]}"
          msg += "\n\nConclusion : \nYou should choose #{better}"
          reply_text(event, msg)

        when 'text', 'teks'
          text = event_msg.split("#{event_msg.split(' ').first} ")[1].gsub(' ', '+')
          tulis = "https://via.placeholder.com/600x100/000000/FFFFFF/?text=#{text}"
          msg = {
            type: 'image',
            originalContentUrl: tulis.to_s,
            previewImageUrl: tulis.to_s
          }
          reply_content(event, msg)

        end
        
      end

    end
  end

end
