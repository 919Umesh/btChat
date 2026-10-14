package com.example.chat_l

import android.bluetooth.*
import android.bluetooth.le.*
import android.content.Context
import android.os.Build
import android.os.ParcelUuid
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.UUID

class MainActivity : FlutterActivity(), MethodChannel.MethodCallHandler {
    private val CHANNEL = "com.example.chat_l/peripheral"

    private val CHAT_SERVICE_UUID = UUID.fromString("0000ffe0-0000-1000-8000-00805f9b34fb")
    private val CHAT_CHAR_UUID = UUID.fromString("0000ffe1-0000-1000-8000-00805f9b34fb")
    private val CCCD_UUID = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb")

    private var methodChannel: MethodChannel? = null
    private var bluetoothManager: BluetoothManager? = null
    private var bluetoothAdapter: BluetoothAdapter? = null
    private var advertiser: BluetoothLeAdvertiser? = null
    private var gattServer: BluetoothGattServer? = null
    private var chatCharacteristic: BluetoothGattCharacteristic? = null

    private var isAdvertising = false
    private val connectedClients = mutableSetOf<BluetoothDevice>()
    private val clientBuffers = mutableMapOf<String, StringBuilder>()

    private val advertiseCallback = object : AdvertiseCallback() {
        override fun onStartSuccess(settingsInEffect: AdvertiseSettings?) {
            isAdvertising = true
        }

        override fun onStartFailure(errorCode: Int) {
            isAdvertising = false
        }
    }

    private val gattServerCallback = object : BluetoothGattServerCallback() {
        override fun onConnectionStateChange(device: BluetoothDevice, status: Int, newState: Int) {
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                connectedClients.add(device)
                runOnUiThread {
                    methodChannel?.invokeMethod("onClientConnected", mapOf("deviceId" to device.address))
                }
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                connectedClients.remove(device)
                clientBuffers.remove(device.address)
                runOnUiThread {
                    methodChannel?.invokeMethod("onClientDisconnected", mapOf("deviceId" to device.address))
                }
            }
        }

        override fun onCharacteristicWriteRequest(
            device: BluetoothDevice,
            requestId: Int,
            characteristic: BluetoothGattCharacteristic,
            preparedWrite: Boolean,
            responseNeeded: Boolean,
            offset: Int,
            value: ByteArray?
        ) {
            if (responseNeeded) {
                try {
                    gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, offset, value)
                } catch (e: SecurityException) {
                    // Ignore missing permission in callback
                }
            }

            if (value != null && value.isNotEmpty()) {
                val chunk = String(value, Charsets.UTF_8)
                val buffer = clientBuffers.getOrPut(device.address) { StringBuilder() }
                buffer.append(chunk)

                if (buffer.contains("\n")) {
                    val messages = buffer.toString().split("\n")
                    for (i in 0 until messages.size - 1) {
                        val completeMsg = messages[i].trim()
                        if (completeMsg.isNotEmpty()) {
                            runOnUiThread {
                                methodChannel?.invokeMethod(
                                    "onMessageReceived",
                                    mapOf(
                                        "senderId" to device.address,
                                        "payload" to completeMsg
                                    )
                                )
                            }
                        }
                    }
                    buffer.clear()
                    buffer.append(messages.last())
                }
            }
        }

        override fun onDescriptorWriteRequest(
            device: BluetoothDevice,
            requestId: Int,
            descriptor: BluetoothGattDescriptor,
            preparedWrite: Boolean,
            responseNeeded: Boolean,
            offset: Int,
            value: ByteArray?
        ) {
            if (responseNeeded) {
                try {
                    gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, offset, value)
                } catch (e: SecurityException) {
                    // Ignore missing permission in callback
                }
            }
        }

        override fun onCharacteristicReadRequest(
            device: BluetoothDevice,
            requestId: Int,
            offset: Int,
            characteristic: BluetoothGattCharacteristic
        ) {
            try {
                gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, offset, characteristic.value)
            } catch (e: SecurityException) {
                // Ignore
            }
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler(this)

        bluetoothManager = getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
        bluetoothAdapter = bluetoothManager?.adapter
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startAdvertising" -> {
                val customName = call.argument<String>("name") ?: ""
                val success = startPeripheral(customName)
                result.success(success)
            }
            "stopAdvertising" -> {
                stopPeripheral()
                result.success(true)
            }
            "sendServerMessage" -> {
                val text = call.argument<String>("text") ?: ""
                val success = sendServerMessage(text)
                result.success(success)
            }
            "getDeviceName" -> {
                val name = getDeviceName()
                result.success(name)
            }
            "isAdvertisingSupported" -> {
                val supported = bluetoothAdapter?.isMultipleAdvertisementSupported ?: false
                result.success(supported)
            }
            else -> result.notImplemented()
        }
    }

    private fun startPeripheral(customName: String): Boolean {
        if (bluetoothAdapter == null || !bluetoothAdapter!!.isEnabled) {
            return false
        }

        advertiser = bluetoothAdapter?.bluetoothLeAdvertiser
        if (advertiser == null) {
            return false
        }

        startGattServer()

        val settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
            .setConnectable(true)
            .setTimeout(0)
            .build()

        val data = AdvertiseData.Builder()
            .setIncludeTxPowerLevel(false)
            .setIncludeDeviceName(false)
            .addServiceUuid(ParcelUuid(CHAT_SERVICE_UUID))
            .build()

        val scanResponse = AdvertiseData.Builder()
            .setIncludeDeviceName(true)
            .build()

        try {
            advertiser?.stopAdvertising(advertiseCallback)
            advertiser?.startAdvertising(settings, data, scanResponse, advertiseCallback)
            isAdvertising = true
            return true
        } catch (e: SecurityException) {
            return false
        } catch (e: Exception) {
            return false
        }
    }

    private fun startGattServer() {
        if (gattServer != null) return

        try {
            gattServer = bluetoothManager?.openGattServer(this, gattServerCallback)
            val service = BluetoothGattService(CHAT_SERVICE_UUID, BluetoothGattService.SERVICE_TYPE_PRIMARY)

            val char = BluetoothGattCharacteristic(
                CHAT_CHAR_UUID,
                BluetoothGattCharacteristic.PROPERTY_READ or
                        BluetoothGattCharacteristic.PROPERTY_WRITE or
                        BluetoothGattCharacteristic.PROPERTY_WRITE_NO_RESPONSE or
                        BluetoothGattCharacteristic.PROPERTY_NOTIFY,
                BluetoothGattCharacteristic.PERMISSION_READ or
                        BluetoothGattCharacteristic.PERMISSION_WRITE
            )

            val cccd = BluetoothGattDescriptor(
                CCCD_UUID,
                BluetoothGattDescriptor.PERMISSION_READ or BluetoothGattDescriptor.PERMISSION_WRITE
            )
            cccd.value = BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE
            char.addDescriptor(cccd)

            service.addCharacteristic(char)
            gattServer?.addService(service)
            chatCharacteristic = char
        } catch (e: SecurityException) {
            // Permission missing
        } catch (e: Exception) {
            // Ignore
        }
    }

    private fun stopPeripheral() {
        try {
            if (isAdvertising) {
                advertiser?.stopAdvertising(advertiseCallback)
                isAdvertising = false
            }
            gattServer?.close()
            gattServer = null
            chatCharacteristic = null
            connectedClients.clear()
            clientBuffers.clear()
        } catch (e: SecurityException) {
            // Ignore
        }
    }

    private fun sendServerMessage(text: String): Boolean {
        val char = chatCharacteristic ?: return false
        val bytes = (text + "\n").toByteArray(Charsets.UTF_8)

        val chunkSize = 20
        for (device in connectedClients) {
            for (i in 0 until bytes.size step chunkSize) {
                val end = minOf(i + chunkSize, bytes.size)
                val chunk = bytes.copyOfRange(i, end)

                try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        gattServer?.notifyCharacteristicChanged(device, char, false, chunk)
                    } else {
                        @Suppress("DEPRECATION")
                        char.value = chunk
                        @Suppress("DEPRECATION")
                        gattServer?.notifyCharacteristicChanged(device, char, false)
                    }
                } catch (e: SecurityException) {
                    return false
                }
            }
        }
        return true
    }

    private fun getDeviceName(): String {
        return try {
            bluetoothAdapter?.name ?: Build.MODEL ?: "BT Chat Peer"
        } catch (e: SecurityException) {
            Build.MODEL ?: "BT Chat Peer"
        }
    }

    override fun onDestroy() {
        stopPeripheral()
        super.onDestroy()
    }
}
