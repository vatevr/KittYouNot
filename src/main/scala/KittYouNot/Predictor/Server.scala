package KittYouNot.Predictor

import java.net.InetSocketAddress

import com.sun.net.httpserver.{HttpExchange, HttpServer}
import javax.imageio.ImageIO
import org.json4s.DefaultFormats
import org.json4s.native.Serialization

class Server(address: InetSocketAddress, entryPoint: String, model: Model) {
  private val server = HttpServer.create(address, 0)

  server.createContext(entryPoint, (http: HttpExchange) => {
    val headers = http.getRequestHeaders

    val (httpCode, json) = if (headers.containsKey("Content-Type") && headers.getFirst("Content-Type") == "image/jpeg") {
      val image = ImageIO.read(http.getRequestBody)
      val predictionSeq = model.predict(image)
      (200, Map("prediction" -> predictionSeq))
    } else (400, Map("error" -> "Invalid Content"))

    val responseJson = Serialization.write(json)(DefaultFormats)
    val httpOs = http.getResponseBody

    http.getResponseHeaders.set("Content-Type", "application/json")
    http.sendResponseHeaders(httpCode, responseJson.length)
    httpOs.write(responseJson.getBytes())
    httpOs.close()
  })

  def stop(): Unit = server.stop(0)

  def start() = server.start()

}