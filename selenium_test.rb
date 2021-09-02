require "selenium-webdriver"
require "slack-notifier"

WEBHOOK_URL = "https://hooks.slack.com/services/......."
予約サイトURL = "https://covid19.city.tama.lg.jp/"
driver = Selenium::WebDriver.for :chrome
予約受付コード = "0006974783"
確認番号 = "4377"
前回のテキスト = ""

loop do
  driver.get(予約サイトURL)

  予約受付コードフォーム, 確認番号フォーム = driver.find_elements(:tag_name, "input")

  予約受付コードフォーム.send_keys(予約受付コード)
  確認番号フォーム.send_keys(確認番号)
  確認番号フォーム.send_keys(:return)

  sleep 6
  予約変更ボタン = driver.find_element(:xpath, "//span[contains(text(), '予約の登録・変更')]")
  予約変更ボタン.click
  sleep 6
  空き状況 = driver.find_elements(:xpath, "//div[contains(text(), 'に空きがあります')]").map(&:text).to_s
  puts "#{Time.now}: #{空き状況}"
  unless 前回のテキスト == 空き状況
    notifier = Slack::Notifier.new(
      WEBHOOK_URL,
      channel: "#ワクチン予約",
    )
    notifier.ping "#{空き状況}"
  end
  前回のテキスト = 空き状況
end
