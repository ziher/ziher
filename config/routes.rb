Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :inventory_sources

  root :to => 'journals#default', :defaults => { :journal_type_id => JournalType::FINANCE_TYPE_ID }

  get "users/new"
  post "users" => "users#create"
  devise_for :users
  resources :users do
    member do
      get :block
      get :unblock
      get :promote
      get :demote
    end
  end

  resources :user_group_associations
  resources :groups
  resources :entries
  resources :cash_entries

  get 'journals/default' => 'journals#default', :defaults => { :journal_type_id => JournalType::FINANCE_TYPE_ID }
  get 'journals/close_old' => 'journals#close_old', :as => :close_old
  get 'journals/close_current' => 'journals#close_current', :as => :close_current
  post 'journals/close_to_current' => 'journals#close_to_current', :as => :close_to_current
  get 'journals/open_current' => 'journals#open_current', :as => :open_current
  resources :journals
  get 'journals/:id/open' => 'journals#open', :as => :open_journal
  get 'journals/:id/close' => 'journals#close', :as => :close_journal
  post 'journals/:id/close_to' => 'journals#close_to', :as => :close_to_journal
  get 'journals/type/:journal_type_id' => 'journals#index'
  get 'ksiazka_finansowa' => 'journals#default', :defaults => { :journal_type_id => JournalType::FINANCE_TYPE_ID }, :as => :default_finance_journal
  get 'ksiazka_bankowa' =>  'journals#default', :defaults => { :journal_type_id => JournalType::BANK_TYPE_ID }, :as => :default_bank_journal
  resources :journal_types

  resources :categories
  resources :categories do
    post :sort, on: :collection
  end

  get 'reports/finance_report' => 'reports#finance', :via => :get, :as => 'finance_report'
  get 'reports/finance_one_percent_report' => 'reports#finance_one_percent', :via => :get, :as => 'finance_one_percent_report'
  get 'reports/all_finance_report' => 'reports#all_finance', :via => :get, :as => 'all_finance_report'
  get 'reports/all_finance_one_percent_report' => 'reports#all_finance_one_percent', :via => :get, :as => 'all_finance_one_percent_report'

  get 'inventory_entries/fixed_assets_report' => 'inventory_entries#fixed_assets_report', :via => :get, :as => 'fixed_assets_report'
  get 'inventory_entries/no_units' => 'inventory_entries#no_units_to_show'
  resources :inventory_entries

  resources :units do
    member do
      get :enable
      get :disable
    end
  end
  resources :user_unit_associations

  get "home/index"

  get 'audits/index'
end
