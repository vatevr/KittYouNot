import java.net.InetSocketAddress

import simple.predictor.Config._

object Run extends App {
  val model = new Model(modelPrefix, modelEpoch, modelEdge, threshold, context)

  val server = new Server(new InetSocketAddress(host, port),  entryPoint, model)

  Runtime.getRuntime.addShutdownHook(new Thread(() => server.stop()))

  try server.start() catch {
    case ex: Exception => ex.printStackTrace()
  }

}