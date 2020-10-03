require 'telegram/bot'

class Notification
  def initialize(telegram_api_key:, telegram_chat_id:)
    @telegram_api_key = telegram_api_key
    @telegram_chat_id = telegram_chat_id
  end

  def send_message(text)
    return if telegram_api_key.nil? || telegram_api_key.empty? || telegram_chat_id.nil? || telegram_chat_id.empty?
    Telegram::Bot::Client.run(telegram_api_key) do |bot|
      bot.api.send_message(chat_id: telegram_chat_id, text: text)
    end
    puts 'telegram message sent'
  rescue StandardError => e
    puts "telegram bot error: #{e}"
  end

  private

  attr_reader :telegram_api_key, :telegram_chat_id
end
