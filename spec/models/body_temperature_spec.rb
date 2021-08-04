require 'rails_helper'

RSpec.describe BodyTemperature, type: :model do
  let(:user) { FactoryBot.create(:user) }
  let(:other_user) { FactoryBot.create(:user) }

  it 'ユーザID、体温、検温日があれば有効な状態であること' do
    body_temperature = BodyTemperature.new(
      user: user,
      temperature: 36.0,
      measurement_date: '2021/01/01'
    )
    expect(body_temperature).to be_valid
  end

  it 'ユーザIDが無ければ無効な状態であること' do
    body_temperature = FactoryBot.build(:body_temperature, user: nil)
    body_temperature.valid?
    expect(body_temperature.errors[:user]).to include 'を入力してください'
  end

  it '体温がなければ無効な状態であること' do
    body_temperature = FactoryBot.build(:body_temperature, temperature: nil)
    body_temperature.valid?
    expect(body_temperature.errors[:temperature]).to include 'は不正な値です'
  end

  it '体温が数値でなければ無効な状態であること' do
    body_temperature = FactoryBot.build(:body_temperature, temperature: 'test')
    body_temperature.valid?
    expect(body_temperature.errors[:temperature]).to include 'は不正な値です'
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
    expect(body_temperature.errors[:temperature]).to include 'は不正な値です'
    body_temperature = FactoryBot.build(:body_temperature, temperature: 38.2)
    body_temperature.valid?
    expect(body_temperature.errors[:temperature]).to include 'は不正な値です'
  end

  it '検温日がなければ無効な状態であること' do
    body_temperature = FactoryBot.build(:body_temperature, measurement_date: nil)
    body_temperature.valid?
    expect(body_temperature.errors[:measurement_date]).to include 'を入力してください'
  end

  it 'ユーザに対して重複した検温日なら無効な状態であること' do
    FactoryBot.create(:body_temperature, user: user, measurement_date: '2021/01/01')
    body_temperature = FactoryBot.build(:body_temperature, user: user, measurement_date: '2021/01/01')
    body_temperature.valid?
    expect(body_temperature.errors[:measurement_date]).to include 'はすでに存在します'
    body_temperature = FactoryBot.build(:body_temperature, user: other_user, measurement_date: '2021/01/01')
    expect(body_temperature).to be_valid
  end

  it '35.9から38.1までの体温が格納された配列を取得できること' do
    expect(BodyTemperature.create_body_temperatures_array).to eq [
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
  end

  describe '体温を文字列に変換する' do
    context '体温が38.1以上であるとき' do
      it '「38.1℃以上」という文字列が取得できること' do
        expect(BodyTemperature.convert_body_temperature_display(38.1)).to eq '38.1℃以上'
      end
    end

    context '体温が36.0未満であるとき' do
      it '「36.0℃未満」という文字列が取得できること' do
        expect(BodyTemperature.convert_body_temperature_display(35.9)).to eq '36.0℃未満'
      end
    end

    context '体温が36.0以上38.1未満であるとき' do
      it '「体温の値℃」という文字列が取得できること' do
        expect(BodyTemperature.convert_body_temperature_display(36.0)).to eq '36.0℃'
        expect(BodyTemperature.convert_body_temperature_display(38.0)).to eq '38.0℃'
      end
    end
  end

  it '指定した日付範囲に対応する体温のハッシュを取得できること' do
    [
      { user: user, temperature: 36.1, measurement_date: '2021/01/01' },
      { user: user, temperature: 36.2, measurement_date: '2021/01/02' },
      { user: user, temperature: 36.3, measurement_date: '2021/01/03' },
      { user: other_user, temperature: 37.5, measurement_date: '2021/01/10' },
      { user: other_user, temperature: 37.6, measurement_date: '2021/01/11' }
    ].each do |data|
      FactoryBot.create(:body_temperature, **data)
    end
    date_range = Date.new(2021, 1, 1)..Date.new(2021, 1, 31)
    expect(BodyTemperature.create_body_temperatures_hash_of_user(date_range)).to eq(
      {
        user.id => { 1 => 36.1, 2 => 36.2, 3 => 36.3 },
        other_user.id => { 10 => 37.5, 11 => 37.6 }
      }
    )
  end

  it '体温が小数点以下第二位で切り捨てされていること' do
    body_temperature = FactoryBot.build(:body_temperature, temperature: 36.15432)
    expect { body_temperature.save! }.to change(body_temperature, :temperature).from(36.15432).to(36.1)
  end
end
