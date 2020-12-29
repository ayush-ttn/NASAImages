package ayush.app.NasaImages

import android.content.ContentValues
import android.content.Context
import android.content.ContextWrapper
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.io.IOException
import java.text.SimpleDateFormat
import java.util.*

class MainActivity: FlutterActivity() {
    private val CHANNEL = "ayush.app.nasaImages/image"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            // Note: this method is invoked on the main thread.

            Log.d("TAG", "CALL value ${call.arguments is ByteArray}")
            if (call.method == "saveImage") {
//                var data = call.arguments as Array<Array<byte>>
//                var imageData = data.first()
                //(call.arguments as java.util.ArrayList<*>)[0]

                var value = (call.arguments as java.util.ArrayList<*>)[0] as ByteArray;
                Log.d("Tag", "value = $value")
                val bMap: Bitmap = BitmapFactory.decodeByteArray(value, 0, value.size);
                storeImage(bMap);
//                saveToInternalStorage(bMap);
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }
    private fun storeImage(image: Bitmap) {
        var pictureFile: File? = null
        getOutputMediaFile()?.let { pictureFile = getOutputMediaFile() } ?: return
        try {
            val fos = FileOutputStream(pictureFile)
            image.compress(Bitmap.CompressFormat.PNG, 100, fos)
            fos.close()
            addImageToGallery(pictureFile?.absolutePath, applicationContext)
        } catch (e: FileNotFoundException) {
            Log.d("TAG", "File not found: " + e.message)
        } catch (e: IOException) {
            Log.d("TAG", "Error accessing file: " + e.message)
        }
    }
    fun addImageToGallery(filePath: String?, context: Context) {
        val values = ContentValues()
        values.put(MediaStore.Images.Media.DATE_TAKEN, System.currentTimeMillis())
        values.put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
        values.put(MediaStore.MediaColumns.DATA, filePath)
        context.contentResolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
    }
    private fun getOutputMediaFile(): File? {
        // To be safe, you should check that the SDCard is mounted
        // using Environment.getExternalStorageState() before doing this.

//        val sdcard = Environment.getExternalStorageDirectory();
//        val folder = File(sdcard.absoluteFile, "/Photos");

        val mediaStorageDir = File(Environment.getExternalStorageDirectory().absoluteFile, "/Android/data/"
                + applicationContext.packageName
                + "/Files")
        // This location works best if you want the created images to be shared
        // between applications and persist after your app has been uninstalled.
        // Create the storage directory if it does not exist
        if (!mediaStorageDir.exists()) {
            if (!mediaStorageDir.mkdirs()) {
                return null
            }
        }///storage/emulated/0/Android/data/ayush.app.NasaImages/Files/MI_29122020_2033.jpg
        // Create a media file name
        val timeStamp: String = SimpleDateFormat("ddMMyyyy_HHmm").format(Date())
        val mediaFile: File
        val mImageName = "MI_$timeStamp.jpg"
        mediaFile = File(mediaStorageDir.path + File.separator + mImageName)
        return mediaFile
    }
}
