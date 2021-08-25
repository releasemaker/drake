# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GithubWebhooksController, type: :request do
  context '#create' do
    let(:action) { :post }
    let(:path) { "/github_webhooks" }
    let(:the_request) {
      send(action, path, params: params.to_json, headers: headers)
    }

    context 'with a pull request webhook' do
      let(:params) { parsed_json_fixture('github/hooks/merged_pull_request') }
      let(:headers) {
        {
          'CONTENT_TYPE' => 'application/json',
          'X-GitHub-Event' => 'pull_request',
        }
      }

      before do
        allow(PullRequestHandler).to receive(:new).and_return(push_handler)
      end
      let(:push_handler) { instance_double(PullRequestHandler, handle!: true) }

      it 'validates the signature using github_webhooks'

      context 'when the signature is correct' do
        before do
          allow_any_instance_of(GithubWebhooksController).to receive(:authenticate_github_request!)
            .and_return(true)
        end

        it 'responds with OK' do
          the_request
          expect(response).to have_http_status(:ok)
        end

        it 'creates a PullRequestHandler and calls handle!' do
          the_request
          expect(PullRequestHandler).to have_received(:new).with(hook_payload: params)
          expect(push_handler).to have_received(:handle!)
        end
      end

      context 'when the signature is not correct' do
        before do
          allow_any_instance_of(GithubWebhooksController).to receive(:authenticate_github_request!)
            .and_raise(GithubWebhook::Processor::SignatureError.new('Expected correct signature'))
        end

        it 'responds with Forbidden' do
          the_request
          expect(response).to have_http_status(:forbidden)
        end
      end
    end

    context 'with a push webhook' do
      let(:params) { parsed_json_fixture('github/hooks/push') }
      let(:headers) {
        {
          'CONTENT_TYPE' => 'application/json',
          'X-GitHub-Event' => 'push',
        }
      }

      before do
        allow(PullRequestHandler).to receive(:new).and_return(push_handler)
      end
      let(:push_handler) { instance_double(PullRequestHandler, handle!: true) }

      it 'validates the signature using github_webhooks'

      context 'when the signature is correct' do
        before do
          allow_any_instance_of(GithubWebhooksController).to receive(:authenticate_github_request!)
            .and_return(true)
        end

        it 'responds with OK' do
          the_request
          expect(response).to have_http_status(:ok)
        end

        it 'does not do anything' do
          the_request
          expect(PullRequestHandler).to_not have_received(:new)
        end
      end

      context 'when the signature is not correct' do
        before do
          allow_any_instance_of(GithubWebhooksController).to receive(:authenticate_github_request!)
            .and_raise(GithubWebhook::Processor::SignatureError.new('Expected correct signature'))
        end

        it 'responds with Forbidden' do
          the_request
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end
end
