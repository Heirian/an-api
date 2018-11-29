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
end