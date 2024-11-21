module IndexPage
  def self.content
    <<~HTML
      <body>
        <h1>Welcome to FudoApp-Challenge!</h1>
        <p>
          Visit the following links to get more information:
          <ul>
            <li><a href="/authors">Authors</a></li>
            <li><a href="/openapi">Especification OpenAPI</a></li>
          </ul>
        </p>
      </body>
      <br>
    HTML
  end
end