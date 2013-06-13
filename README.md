# Cybozuget
## Setting

1. config.ymlのユーザー情報とGaroonのアドレスを適切に設定

## Quick Start

1. cd bin
2. ./cybozuget

## Command Install

1. `edit config/config.yml`
2. `git add .`
3. `git commit "edit config.yml"`
4. `rake build`
5. `gem install pkg/cybozuget-0.0.1.gem`

## Usage
### 認証ユーザーの今日の予定
    cybozuget

### スケジュール参加者
    cybozuget -m

###  認証ユーザーの明日の予定
    cybozuget -d 1

### 認証ユーザーの今日から一週間分の予定
    cybozuget -w 7

### 認証ユーザーの特定の日の予定
    cybozuget -s '2013-05-24'
    cybozuget -s '2013-05-24' -e '2013-05-31'

### tanakaさんの今日から10日分のスケジュール
    cybozuget -u tanaka -w 10

### tanakaさんの昨日の予定
    cybozuget -u tanaka -d -1

### cacheしたユーザー情報
    cybozuget -i all
    cybozuget -i tanaka
