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
    when 'materi sem 7'
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
        help += "\nwaifu = sapakah waifu mu?"
        help += "\n/kuliah = info kuliah"
        help += "\n/dosen = list kontak dosen"
        help += "\n/help = list command"
        help += "\n/materisemX = list materi sem X, gnti X dgn 1-7"
        help += "\n/fun = list fun stuff"
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

      when '/materisem1'
        reply_content(event,
                      type: 'template',
                      altText: 'List Materi Sem 1',
                      template: {
                        type: 'carousel',
                        columns: [
                          {
                            title: 'Page 1',
                            text: 'Materi Semester I',
                            actions: [
                              { label: 'Algo', type: 'uri', uri: 'http://bit.ly/2W3iHUX' },
                              { label: 'Logika Informatika', type: 'uri', uri: 'http://bit.ly/2Y3Nm6y' },
                              { label: 'Mtk Diskrit', type: 'uri', uri: 'http://bit.ly/2Y3NOlg' }
                            ]
                          },
                          {
                            title: 'Page 2',
                            text: 'Materi Semester I',
                            actions: [
                              { label: 'Konsep Teknologi', type: 'uri', uri: 'http://bit.ly/2Y3NV0a' },
                              { label: 'Empty', type: 'postback', data: 'null' },
                              { label: 'Empty', type: 'postback', data: 'null' }
                            ]
                          },
                          {
                            title: 'Page 3',
                            text: 'Materi Semester I',
                            actions: [
                                { label: 'Empty', type: 'postback', data: 'null' },
                                { label: 'Empty', type: 'postback', data: 'null' },
                                { label: 'Empty', type: 'postback', data: 'null' }
                            ]
                          }
                        ]
                      })

      when '/materisem2'
        reply_content(event,
                      type: 'template',
                      altText: 'List Materi Sem 2',
                      template: {
                        type: 'carousel',
                        columns: [
                          {
                            title: 'Page 1',
                            text: 'Materi Semester II',
                            actions: [
                              { label: 'Olahraga', type: 'uri', uri: 'http://bit.ly/2EwxQ86' },
                              { label: 'Statistika', type: 'uri', uri: 'http://bit.ly/2Ev0C9d' },
                              { label: 'Wimaya', type: 'uri', uri: 'http://bit.ly/2IDE6gM' }
                            ]
                          },
                          {
                            title: 'Page 2',
                            text: 'Materi Semester II',
                            actions: [
                              { label: 'JarKom', type: 'uri', uri: 'http://bit.ly/2Hkp1Bm' },
                              { label: 'Algo Lanjut', type: 'uri', uri: 'http://bit.ly/2GLQTNI' },
                              { label: 'KoMas', type: 'uri', uri: 'http://bit.ly/2EvETOj' }
                            ]
                          },
                          {
                            title: 'Page 3',
                            text: 'Materi Semester II',
                            actions: [
                              { label: 'PKn', type: 'uri', uri: 'http://bit.ly/2GMWOBY' },
                              { label: 'Empty', type: 'postback', data: 'null' },
                              { label: 'Empty', type: 'postback', data: 'null' }
                            ]
                          }
                        ]
                      })

      when '/materisem3'
        reply_content(event,
                      type: 'template',
                      altText: 'List Materi Sem 3',
                      template: {
                        type: 'carousel',
                        columns: [
                          {
                            title: 'Page 1',
                            text: 'Materi Semester III',
                            actions: [
                              { label: 'Struktur Data', type: 'uri', uri: 'http://bit.ly/2wfFstE' },
                              { label: 'PBO', type: 'uri', uri: 'http://bit.ly/2LemGrM' },
                              { label: 'Matriks & RV', type: 'uri', uri: 'http://bit.ly/2MtgqSI' }
                            ]
                          },
                          {
                            title: 'Page 2',
                            text: 'Materi Semester III',
                            actions: [
                              { label: 'Sistem Operasi', type: 'uri', uri: 'http://bit.ly/2P6PTbb' },
                              { label: 'STI', type: 'uri', uri: 'http://bit.ly/2IAabYa' },
                              { label: 'KoNum', type: 'uri', uri: 'http://bit.ly/2IAZVyK' }
                            ]
                          },
                          {
                            title: 'Page 3',
                            text: 'Materi Semester III',
                            actions: [
                              { label: 'OPK', type: 'uri', uri: 'http://bit.ly/2Bxzuu0' },
                              { label: 'Empty', type: 'postback', data: 'null' },
                              { label: 'Empty', type: 'postback', data: 'null' }
                            ]
                          }
                        ]
                      })

      when '/materisem4'
        reply_content(event,
                      type: 'template',
                      altText: 'List Materi Sem 4',
                      template: {
                        type: 'carousel',
                        columns: [
                          {
                            title: 'Page 1',
                            text: 'Materi Semester IV',
                            actions: [
                              { label: 'Analisa Algo', type: 'uri', uri: 'http://bit.ly/2BiIIrg' },
                              { label: 'Sistem Digital', type: 'uri', uri: 'http://bit.ly/2G36jk1' },
                              { label: 'Basis Data', type: 'uri', uri: 'http://bit.ly/2DROdix' }
                            ]
                          },
                          {
                            title: 'Page 2',
                            text: 'Materi Semester IV',
                            actions: [
                              { label: 'AOK', type: 'uri', uri: 'http://bit.ly/2IvhdRy' },
                              { label: 'Geoinformatika', type: 'uri', uri: 'http://bit.ly/2SffPC8' },
                              { label: 'IMK', type: 'uri', uri: 'http://bit.ly/2VPn71v' }
                            ]
                          },
                          {
                            title: 'Page 3',
                            text: 'Materi Semester IV',
                            actions: [
                              { label: 'TPM', type: 'uri', uri: 'http://bit.ly/2HtgxK4' },
                              { label: 'Empty', type: 'postback', data: 'null' },
                              { label: 'Empty', type: 'postback', data: 'null' }
                            ]
                          }
                        ]
                      })

      when '/materisem5'
        reply_content(event,
                      type: 'template',
                      altText: 'List Materi Sem 5',
                      template: {
                        type: 'carousel',
                        columns: [
                          {
                            title: 'Page 1',
                            text: 'Materi Semester V',
                            actions: [
                              { label: 'Riset Operasi', type: 'uri', uri: 'http://bit.ly/2DSQjR4' },
                              { label: 'Empty', type: 'postback', data: 'null' },
                              { label: 'Empty', type: 'postback', data: 'null' }
                            ]
                          },
                          {
                            title: 'Page 2',
                            text: 'Materi Semester V',
                            actions: [
                              { label: 'Empty', type: 'postback', data: 'null' },
                              { label: 'Empty', type: 'postback', data: 'null' },
                              { label: 'Empty', type: 'postback', data: 'null' }
                            ]
                          },
                          {
                            title: 'Page 3',
                            text: 'Materi Semester V',
                            actions: [
                                { label: 'Empty', type: 'postback', data: 'null' },
                                { label: 'Empty', type: 'postback', data: 'null' },
                                { label: 'Empty', type: 'postback', data: 'null' }
                            ]
                          }
                        ]
                      })

      when '/materisem6'
        reply_content(event,
                      type: 'template',
                      altText: 'List Materi Sem 6',
                      template: {
                        type: 'carousel',
                        columns: [
                          {
                            title: 'Page 1',
                            text: 'Materi Semester VI',
                            actions: [
                              { label: 'ADBO', type: 'uri', uri: 'http://bit.ly/2V9ZjFi' },
                              { label: 'Grafkom', type: 'uri', uri: 'http://bit.ly/2Om7Hzh' },
                              { label: 'Empty', type: 'postback', data: 'null' }
                            ]
                          },
                          {
                            title: 'Page 2',
                            text: 'Materi Semester VI',
                            actions: [
                              { label: 'Empty', type: 'postback', data: 'null' },
                              { label: 'Empty', type: 'postback', data: 'null' },
                              { label: 'Empty', type: 'postback', data: 'null' }
                            ]
                          },
                          {
                            title: 'Page 3',
                            text: 'Materi Semester VI',
                            actions: [
                              { label: 'Empty', type: 'postback', data: 'null' },
                              { label: 'Empty', type: 'postback', data: 'null' },
                              { label: 'Empty', type: 'postback', data: 'null' }
                            ]
                          }
                        ]
                      })

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
        topics = %w[life motivational smile positive nature family love inspirational].sample
        quote_url = "https://www.brainyquote.com/topics/#{topics}"
        quote_data = Nokogiri::HTML(open(quote_url))
        quotes = quote_data.css('.bq_center').css('.reflow_body').css('.reflow_container').css('.clearfix a').map do |a|
          a['title'] == 'view quote' ? a.text : ''
        end
        authors = quote_data.css('.bq_center').css('.reflow_body').css('.reflow_container').css('.clearfix a').map do |a|
          a['title'] == 'view author' ? a.text : ''
        end
        quotes.uniq!
        authors.uniq!
        quotes.delete_at(quotes.index(''))
        authors.delete_at(authors.index(''))
        random_number = rand(0..quotes.size)
        quote = quotes[random_number]
        author = authors[random_number]
        msg = "\"#{quote}\" \n~ #{author}"
        reply_text(event, msg)

      when 'waifu'
        url = 'https://random-waifu-api-ror.herokuapp.com/random-waifu'
        data = Net::HTTP.get(URI(url))
        waifu = JSON.parse(data)
        name = waifu['name']
        image = waifu['imgwaifu']
        reply_content(event,[
                        {
                          type: 'text',
                          text: "Your Waifu is #{name}"
                        },
                        {
                          type: 'image',
                          originalContentUrl: image.to_s,
                          previewImageUrl: image.to_s
                        }
                      ])

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
                          { label: 'Fun Stuff', type: 'message', text: '/fun' }
                        ]
                      })

      when '/fun'
        reply_content(event,
                      type: 'template',
                      altText: 'Fun Stuff',
                      template: {
                        type: 'buttons',
                        thumbnailImageUrl: 'https://via.placeholder.com/1024/000000/FFFFFF/?text=Fun+Stuff',
                        title: 'Fun Stuff',
                        text: "Let's play and have fun!",
                        actions: [
                          { label: 'Give me a quote!', type: 'message', text: 'quote' },
                          { label: 'Test your luck!', type: 'message', text: 'roll' },
                          { label: 'Who is ur waifu?', type: 'message', text: 'waifu' },
                          { label: 'Who are you?', type: 'message', text: 'profile' }
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
                              { label: 'Materi Sem I', type: 'message', text: '/materisem1' },
                              { label: 'Materi Sem II', type: 'message', text: '/materisem2' },
                              { label: 'Materi Sem III', type: 'message', text: '/materisem3' }
                            ]
                          },
                          {
                            title: 'Page 2',
                            text: 'Materi Semester IV, V, VI',
                            actions: [
                              { label: 'Materi Sem IV', type: 'message', text: '/materisem4' },
                              { label: 'Materi Sem V', type: 'message', text: '/materisem5' },
                              { label: 'Materi Sem VI', type: 'message', text: '/materisem6' }
                            ]
                          },
                          {
                            title: 'Page 3',
                            text: 'Materi Semester VII',
                            actions: [
                              { label: 'Materi Sem VII', type: 'postback', data: 'materi sem 7' },
                              { label: 'Empty', type: 'postback', data: 'null' },
                              { label: 'Empty', type: 'postback', data: 'null' }
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
