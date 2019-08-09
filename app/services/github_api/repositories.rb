module GithubApi
  class Repositories
    include HttpStatusCodes
    include ApiExceptions

    API_ENDPOINT = 'https://api.github.com'.freeze
    API_REQUSTS_QUOTA_REACHED_MESSAGE = 'API rate limit exceeded'.freeze

    def initialize(search_params)
      @search_term = search_params[:search_term]
      @language = search_params[:language]
      @sort = search_params[:sort]
      @order = search_params[:order]
      @page = search_params[:page]
    end

    def call
      #binding.pry
      validate_request
      search_repos
    end

    def search_repos
      request(
          http_method: :get,
          endpoint: "search/repositories?",
          params: { q: @search_term, sort: @sort, order: @order, page: @page }
      )
    end


    private

    def validate_request
      raise NotFoundError, "Code: #{HTTP_NOT_FOUND_CODE}, response: Search text can not be blank." if @search_term.blank?
    end

    def request(http_method:, endpoint:, params: {})
      @response = client.public_send(http_method, endpoint, params)
      parsed_response = Oj.load(@response.body)

      return parsed_response if response_successful?

      raise error_class, "Code: #{@response.status}, response: #{@response.body}"
    end

    def client
      @_client ||= Faraday.new(API_ENDPOINT) do |client|
        client.request :url_encoded
        client.adapter Faraday.default_adapter
        client.headers['Accept'] = "application/vnd.github.mercy-preview+json"
      end
    end

    def error_class
      case @response.status
        when HTTP_BAD_REQUEST_CODE
          BadRequestError
        when HTTP_UNAUTHORIZED_CODE
          UnauthorizedError
        when HTTP_FORBIDDEN_CODE
          return ApiRequestsQuotaReachedError if api_requests_quota_reached?
          ForbiddenError
        when HTTP_NOT_FOUND_CODE
          NotFoundError
        when HTTP_UNPROCESSABLE_ENTITY_CODE
          UnprocessableEntityError
        else
          ApiError
      end
    end

    def response_successful?
      @response.status == HTTP_OK_CODE
    end

    def api_requests_quota_reached?
      @response.body.match?(API_REQUSTS_QUOTA_REACHED_MESSAGE)
    end

  end
end