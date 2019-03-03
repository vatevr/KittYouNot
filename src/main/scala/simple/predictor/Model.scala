import java.awt.image.BufferedImage

import org.apache.mxnet._
import _root_.Model.Prediction
import org.apache.mxnet.infer.{ObjectDetector, Predictor}

class Model(prefix: String, epoch: Int, imageEdge: Int, threshold: Float, context: Context) {
  val initShape = new Shape(3, 3, imageEdge, imageEdge)

  val initData = new DataDesc(name = "data", initShape, DType.Float32, Layout.NCHW)

  val model = new ObjectDetector(prefix, IndexedSeq(initData), context, Option(epoch))

  private def toPrediction(originalWidth: Int, originalHeight: Int)(predict: (String, Array[Float])): Prediction = {
    val (objectClass, Array(probability, kx, ky, kw, kh)) = predict

    val x = (originalWidth * kx).toInt
    val y = (originalHeight * ky).toInt
    val w = (originalWidth * kw).toInt
    val h = (originalHeight * kh).toInt

    val width = if (x + w < originalWidth) w else originalWidth - x
    val height = if (y + h < originalHeight) w else originalHeight - y

    Model.Prediction(objectClass, probability, x, y, width, height)
  }

  def predict(image: BufferedImage): Seq[Prediction] =
    model.imageObjectDetect(image).head map toPrediction(image.getWidth, image.getHeight) filter (_.probability > threshold)
}

object Model {
  case class Prediction(objectClass: String, probability: Float, x: Int, y: Int, width: Int, height: Int)
}