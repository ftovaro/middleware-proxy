require 'rack/proxy'

class CustomInterceptorMiddleware < Rack::Proxy
  def perform_request(env)
    if intercept_request?(env)
      response_headers = {
        "Content-Type" => "text/plain",
        "Backstage-Kubernetes-Cluster" => "ftovar-cluster",
        "X-Auth-Metadata" => {},

        # CORS headers
        "Access-Control-Allow-Origin" => "*",
        "Access-Control-Allow-Methods" => "POST, GET, OPTIONS, DELETE, PUT",
        "Access-Control-Allow-Headers" => "x-requested-with, Content-Type, origin, authorization, accept, client-security-token"
      }

      text = Array.new(1200, "Lorem").join("\n")

      [
        200,
        response_headers,
        ["#{text}\n"]
      ]
    else
      super
    end
  end

  def intercept_request?(env)
    env['REQUEST_METHOD'] == 'GET' &&
      env['REQUEST_PATH'] == '/api/k8s-custom-apis/v1/namespaces/my-apps/pods/tanzu-java-web-app-pr-flow-4-build-1-build-pod/log' &&
      env['QUERY_STRING'].include?('container=prepare&follow=true&timestamps=true')
  end
end
