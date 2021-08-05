require 'rails_helper'

RSpec.describe User, type: :model do
  it '名前、メールアドレス、パスワードがあれば有効な状態であること' do
    user = User.new(
      name: 'user name',
      email: 'user@example.com',
      password: 'password'
    )
    expect(user).to be_valid
  end

  it '名前が無ければ無効な状態であること' do
    user = FactoryBot.build(:user, name: nil)
    user.valid?
    expect(user.errors[:name]).to include 'を入力してください'
  end

  it 'メールアドレスがなければ無効な状態であること' do
    user = FactoryBot.build(:user, email: nil)
    user.valid?
    expect(user.errors[:email]).to include 'を入力してください'
  end

  describe 'メールアドレスのフォーマット検証' do
    context 'フォーマットに沿っているとき' do
      it 'メールアドレスが有効な状態であること' do
        user = FactoryBot.build(:user, email: 'user@example.com')
        expect(user).to be_valid
      end
    end

    context 'フォーマットに沿っていないとき' do
      it 'メールアドレスが無効な状態であること' do
        [
          'user@example,com',
          '  @example.com',
          'user@  .com',
          'user_at_foo.org',
          'user.name@example.',
          'foo@bar_baz.com',
          'foo@bar+baz.com'
        ].each do |invalid_address|
          user = FactoryBot.build(:user, email: invalid_address)
          user.valid?
          expect(user.errors[:email]).to include 'は不正な値です'
        end
      end
    end
  end

  it '重複したメールアドレスなら無効な状態であること' do
    FactoryBot.create(:user, email: 'user@example.com')
    other_user = FactoryBot.build(:user, email: 'user@example.com')
    expect(other_user).not_to be_valid
    expect(other_user.errors[:email]).to include 'はすでに存在します'
  end

  it 'メールアドレスが小文字化されていること' do
    user = FactoryBot.build(:user, email: 'USER@example.com')
    expect { user.save! }.to change(user, :email).from('USER@example.com').to('user@example.com')
  end
end
