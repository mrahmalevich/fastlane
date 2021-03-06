require 'fastlane_core'
require 'credentials_manager'
Dir[File.dirname(__FILE__) + '/rules/*.rb'].each { |file| require file }

module Precheck
  class Options
    def self.rules
      [
        NegativeAppleSentimentRule,
        PlaceholderWordsRule,
        OtherPlatformsRule,
        FutureFunctionalityRule,
        TestWordsRule,
        CurseWordsRule,
        FreeStuffIAPRule,
        CustomTextRule,
        CopyrightDateRule,
        UnreachableURLRule
      ].map(&:new)
    end

    def self.available_options
      user = CredentialsManager::AppfileConfig.try_fetch_value(:itunes_connect_id)
      user ||= CredentialsManager::AppfileConfig.try_fetch_value(:apple_id)

      [
        FastlaneCore::ConfigItem.new(key: :app_identifier,
                                     short_option: "-a",
                                     env_name: "PRECHECK_APP_IDENTIFIER",
                                     description: "The bundle identifier of your app",
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)),
        FastlaneCore::ConfigItem.new(key: :username,
                                     short_option: "-u",
                                     env_name: "PRECHECK_USERNAME",
                                     description: "Your Apple ID Username",
                                     default_value: user),
        FastlaneCore::ConfigItem.new(key: :team_id,
                                     short_option: "-b",
                                     env_name: "PRECHECK_TEAM_ID",
                                     description: "The ID of your iTunes Connect team if you're in multiple teams",
                                     optional: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_id),
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_ITC_TEAM_ID"] = value.to_s
                                     end),
        FastlaneCore::ConfigItem.new(key: :team_name,
                                     short_option: "-l",
                                     env_name: "PRECHECK_TEAM_NAME",
                                     description: "The name of your iTunes Connect team if you're in multiple teams",
                                     optional: true,
                                     default_value: CredentialsManager::AppfileConfig.try_fetch_value(:itc_team_name),
                                     verify_block: proc do |value|
                                       ENV["FASTLANE_ITC_TEAM_NAME"] = value.to_s
                                     end),
        FastlaneCore::ConfigItem.new(key: :default_rule_level,
                                     short_option: "-r",
                                     env_name: "PRECHECK_DEFAULT_RULE_LEVEL",
                                     description: "The default rule level unless otherwise configured",
                                     is_string: false,
                                     default_value: RULE_LEVELS[:error]),
        FastlaneCore::ConfigItem.new(key: :include_in_app_purchases,
                                     short_option: "-i",
                                     env_name: "PRECHECK_INCLUDE_IN_APP_PURCHASES",
                                     description: "Should check in-app purchases?",
                                     is_string: false,
                                     optional: true,
                                     default_value: true)
      ] + rules
    end
  end
end
