require 'rails_helper'

RSpec.describe BodyTemperature, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }

  it 'ユーザID、体温、検温日があれば有効な状態であること' do
    body_temperature = BodyTemperature.new(
      user_id: user.id,
      temperature: 36.0,
      measurement_date: '2021/01/01'
    )
    expect(body_temperature).to be_valid
  end

  it 'ユーザIDが無ければ無効な状態であること' do
    body_temperature = FactoryBot.build(:body_temperature, user_id: nil)
    body_temperature.valid?
    expect(body_temperature.errors[:user]).to include('を入力してください')
  end

  it '体温がなければ無効な状態であること' do
    body_temperature = FactoryBot.build(:body_temperature, temperature: nil)
    body_temperature.valid?
    expect(body_temperature.errors[:temperature]).to include('は不正な値です')
  end

  it '体温が数値でなければ無効な状態であること' do
    body_temperature = FactoryBot.build(:body_temperature, temperature: 'test')
    body_temperature.valid?
    expect(body_temperature.errors[:temperature]).to include('は不正な値です')
  end

  it '体温が35.9以上38.1以下であれば有効な状態であること' do
    body_temperature = FactoryBot.build(:body_temperature, temperature: 35.9)
    expect(body_temperature).to be_valid
    body_temperature = FactoryBot.build(:body_temperature, temperature: 38.1)
    expect(body_temperature).to be_valid
  end

  it '体温が35.8以下又は38.2以上であれば無効な状態であること' do
    body_temperature = FactoryBot.build(:body_temperature, temperature: 35.8)
    body_temperature.valid?
    expect(body_temperature.errors[:temperature]).to include('は不正な値です')
    body_temperature = FactoryBot.build(:body_temperature, temperature: 38.2)
    body_temperature.valid?
    expect(body_temperature.errors[:temperature]).to include('は不正な値です')
  end

  it '35.9から38.1までの体温が格納された配列を取得できること' do
    expect_body_temperatures_array = [
      ['36.0℃未満', 35.9],
      ['36.0', 36.0],
      ['36.1', 36.1],
      ['36.2', 36.2],
      ['36.3', 36.3],
      ['36.4', 36.4],
      ['36.5', 36.5],
      ['36.6', 36.6],
      ['36.7', 36.7],
      ['36.8', 36.8],
      ['36.9', 36.9],
      ['37.0', 37.0],
      ['37.1', 37.1],
      ['37.2', 37.2],
      ['37.3', 37.3],
      ['37.4', 37.4],
      ['37.5', 37.5],
      ['37.6', 37.6],
      ['37.7', 37.7],
      ['37.8', 37.8],
      ['37.9', 37.9],
      ['38.0', 38.0],
      ['38.1℃以上', 38.1]
    ]
    expect(BodyTemperature.create_body_temperatures_array).to eq expect_body_temperatures_array
  end

  describe '体温を文字列に変換する' do
    context '体温が38.1以上であるとき' do
      it '「38.1℃ 以上」という文字列が取得できること' do
        expect(BodyTemperature.convert_body_temperature_display(38.1)).to eq '38.1℃以上'
      end
    end

    context '体温が36.0未満であるとき' do
      it '「36.0℃ 未満」という文字列が取得できること' do
        expect(BodyTemperature.convert_body_temperature_display(35.9)).to eq '36.0℃未満'
      end
    end

    context '体温が36.0以上38.1未満であるとき' do
      it '「体温の値℃ 」という文字列が取得できること' do
        expect(BodyTemperature.convert_body_temperature_display(36.0)).to eq '36.0℃'
        expect(BodyTemperature.convert_body_temperature_display(38.0)).to eq '38.0℃'
      end
    end
  end

  it '指定した日付範囲に対応する体温のハッシュを取得できること' do
    FactoryBot.create(:body_temperature, user_id: user.id, temperature: 36.1, measurement_date: '2021/01/01')
    FactoryBot.create(:body_temperature, user_id: user.id, temperature: 36.2, measurement_date: '2021/01/02')
    FactoryBot.create(:body_temperature, user_id: user.id, temperature: 36.3, measurement_date: '2021/01/03')
    FactoryBot.create(:body_temperature, user_id: other_user.id, temperature: 37.5, measurement_date: '2021/01/10')
    FactoryBot.create(:body_temperature, user_id: other_user.id, temperature: 37.6, measurement_date: '2021/01/11')
    expect_body_temperatures_hash = Hash.new { |h, k| h[k] = {} }
    expect_body_temperatures_hash[1][1] = 36.1
    expect_body_temperatures_hash[1][2] = 36.2
    expect_body_temperatures_hash[1][3] = 36.3
    expect_body_temperatures_hash[2][10] = 37.5
    expect_body_temperatures_hash[2][11] = 37.6
    date_start = Date.new(2021, 1, 1)
    date_end = Date.new(2021, 1, 31)
    date_range = date_start..date_end
    expect(BodyTemperature.create_body_temperatures_hash_of_user(date_range)).to eq expect_body_temperatures_hash
  end

  it '体温の小数点以下の有効桁数が1桁にされていること' do
    body_temperature = FactoryBot.build(:body_temperature, temperature: 36.15432)
    body_temperature.save
    expect(body_temperature[:temperature]).to eq(36.1)
  end
end
