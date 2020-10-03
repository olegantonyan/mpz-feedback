require 'telegram/bot'

class Notification
  def initialize(telegram_api_key:, telegram_chat_id:)
    @telegram_api_key = telegram_api_key
    @telegram_chat_id = telegram_chat_id
  end

  def send_message(text)
    Telegram::Bot::Client.run(telegram_api_key) do |bot|
      bot.api.send_message(chat_id: telegram_chat_id , text: text)
    end
  end

  private

  attr_reader :telegram_api_key, :telegram_chat_id
end
