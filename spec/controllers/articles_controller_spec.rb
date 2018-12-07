# frozen_string_literal: true

require 'rails_helper'

describe ArticlesController, type: :controller do
  describe '#index' do
    subject { get :index }

    it 'should return success response' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'should return proper json' do
      create_list(:article, 2)
      subject
      expect(json_data.length).to eq(2)
      Article.recent.each_with_index do |article, index|
        expect(json_data[index]['attributes']).to eq(
          'title' => article.title,
          'content' => article.content,
          'slug' => article.slug
        )
      end
    end

    it 'should return articles in the proper order' do
      old_article = create(:article)
      newer_article = create(:article)
      subject
      expect(json_data[0]['id']).to eq(newer_article.id.to_s)
      expect(json_data[-1]['id']).to eq(old_article.id.to_s)
    end

    it 'should paginate results' do
      create_list(:article, 3)
      get :index, params: { page: 2, per_page: 1 }
      expect(json_data.length).to eq(1)
      expected_article = Article.recent.second.id.to_s
      expect(json_data[0]['id']).to eq(expected_article)
    end
  end

  describe '#show' do
    let(:article) { create(:article) }
    subject { get :show, params: { id: article.id } }

    it 'should return success response' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'should return proper article json' do
      subject
      expect(json_data.class).to eq(Hash)
      expect(json_data['attributes']).to eq(
        'title' => article.title,
        'content' => article.content,
        'slug' => article.slug
      )
    end
  end

  describe '#create' do
    subject { post :create }

    context 'when no code provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid code provided' do
      before { request.headers['authorization'] = 'Invalid token' }

      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid parameters provided' do
      let(:invalid_attributes) do
        {
          'data' => {
            'attributes' => {
              'title' => '',
              'content' => '',
              'slug' => ''
            }
          }
        }
      end

      subject { post :create, params: invalid_attributes }
      let(:access_token) { create(:access_token) }
      before do
        request.headers['authorization'] = "Bearer #{access_token.token}"
      end

      it 'should return 422 status code' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'should return proper error json' do
        subject
        expect(json['errors']).to include(
          {
            'source' => { 'pointer' => '/data/attributes/title' },
            'detail' => 'can\'t be blank'
          },
          {
            'source' => { 'pointer' => '/data/attributes/content' },
            'detail' => 'can\'t be blank'
          },
          'source' => { 'pointer' => '/data/attributes/slug' },
          'detail' => 'can\'t be blank'
        )
      end
    end

    context 'when success request sent' do
      let(:valid_attributes) do
        {
          'data' => {
            'attributes' => {
              'title' => 'Awesome-article',
              'content' => 'Super content',
              'slug' => 'awesome-article'
            }
          }
        }
      end

      subject { post :create, params: valid_attributes }
      let(:access_token) { create(:access_token) }
      before do
        request.headers['authorization'] = "Bearer #{access_token.token}"
      end

      it 'should have 201 status code' do
        subject
        expect(response).to have_http_status(:created)
      end

      it 'should have proper json body' do
        subject
        expect(json_data['attributes']).to include(
          valid_attributes['data']['attributes']
        )
      end

      it 'should create the article' do
        expect { subject }.to change { Article.count }.by(1)
      end
    end
  end

  describe '#update' do
    let(:user) { create(:user) }
    let(:article) { create(:article, user: user) }
    let(:access_token) { user.create_access_token }
    subject { put :update, params: { id: article.id } }

    context 'when no code provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid code provided' do
      before { request.headers['authorization'] = 'Invalid code' }
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid params' do
      let(:invalid_attributes) do
        {
          'id' => article.id,
          'data' => {
            'attributes' => {
              'title' => '',
              'content' => '',
              'slug' => ''
            }
          }
        }
      end
      subject { put :update, params: invalid_attributes }
      before do
        request.headers['authorization'] = "Bearer #{access_token.token}"
      end

      it 'should return 422 status code' do
        subject
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'should return proper error json' do
        subject
        expect(json['errors']).to include(
          {
            'source' => { 'pointer' => '/data/attributes/title' },
            'detail' => 'can\'t be blank'
          },
          {
            'source' => { 'pointer' => '/data/attributes/content' },
            'detail' => 'can\'t be blank'
          },
          'source' => { 'pointer' => '/data/attributes/slug' },
          'detail' => 'can\'t be blank'
        )
      end
    end

    context 'when trying to update not owned article' do
      let(:other_user) { create(:user) }
      let(:other_article) { create(:article, user: other_user) }

      subject { patch :update, params: { id: other_article.id } }
      before do
        request.headers['authorization'] = "Bearer #{access_token.token}"
      end

      it_behaves_like 'forbidden_requests'
    end

    context 'when success request sent' do
      let(:valid_attributes) do
        {
          'id' => article.id,
          'data' => {
            'attributes' => {
              'title' => 'New title',
              'content' => 'New content',
              'slug' => 'new-title'
            }
          }
        }
      end

      subject { put :update, params: valid_attributes }
      before do
        request.headers['authorization'] = "Bearer #{access_token.token}"
      end

      it 'should return 200 status code' do
        subject
        expect(response).to have_http_status(:ok)
      end

      it 'should have proper json body' do
        subject
        expect(json_data['attributes']).to include(
          valid_attributes['data']['attributes']
        )
      end

      it 'shouldn\'t create a new article' do
        article
        expect { subject }.to change { Article.count }.by(0)
      end
    end
  end

  describe '#destroy' do
    let(:user) { create(:user) }
    let(:article) { create(:article, user: user) }
    let(:access_token) { user.create_access_token }
    subject { delete :destroy, params: { id: article.id } }

    context 'when no code provided' do
      it_behaves_like 'forbidden_requests'
    end

    context 'when invalid code provided' do
      before { request.headers['authorization'] = 'Invalid code' }
      it_behaves_like 'forbidden_requests'
    end

    context 'when trying to destroy not owned article' do
      let(:other_user) { create(:user) }
      let(:other_article) { create(:article, user: other_user) }

      subject { delete :destroy, params: { id: other_article.id } }
      before do
        request.headers['authorization'] = "Bearer #{access_token.token}"
      end

      it_behaves_like 'forbidden_requests'
    end

    context 'when success request sent' do
      subject { delete :destroy, params: { id: article.id } }
      before do
        request.headers['authorization'] = "Bearer #{access_token.token}"
      end

      it 'should return 204 status code' do
        subject
        expect(response).to have_http_status(:no_content)
      end

      it 'should have proper json body' do
        subject
        expect(response.body).to be_blank
      end

      it 'should destroy the article' do
        article
        expect { subject }.to change { user.articles.count }.by(-1)
      end
    end
  end
end
