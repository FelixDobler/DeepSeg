import tensorflow.compat.v1 as tf

tf.disable_v2_behavior()

import nn
import keras

init_kernel = tf.random_normal_initializer(mean=0, stddev=0.05)


def leakyReLu(x, alpha=0.2, name=None):
    if name:
        with tf.variable_scope(name):
            return _leakyReLu_impl(x, alpha)
    else:
        return _leakyReLu_impl(x, alpha)


def _leakyReLu_impl(x, alpha):
    return tf.nn.relu(x) - (alpha * tf.nn.relu(-x))


def gaussian_noise_layer(input_layer, std):
    noise = tf.random_normal(
        shape=tf.shape(input_layer), mean=0.0, stddev=std, dtype=tf.float32
    )
    return input_layer + noise


def classifier(inp, is_training, init=False, reuse=False, getter=None, category=125):
    with tf.variable_scope("discriminator_model", reuse=reuse, custom_getter=getter):
        counter = {}
        # x = tf.reshape(inp, [-1, 200, 30, 3]) # DeepSeg
        x = tf.reshape(inp, [-1, 100, 30, 3])  # Adjusted
        print(x.shape)
        x = keras.layers.Dropout(0.2)(x)

        print(x.shape)
        x = nn.conv2d(x, 96, nonlinearity=leakyReLu, init=init, counters=counter)
        print(x.shape)
        x = nn.conv2d(x, 96, nonlinearity=leakyReLu, init=init, counters=counter)
        # Different strides needed to produce compatible shapes, [5,2] in DeepSeg, [2,2] in this code
        x = nn.conv2d(
            x, 96, stride=[2, 2], nonlinearity=leakyReLu, init=init, counters=counter
        )

        print(x.shape)
        x = keras.layers.Dropout(0.5)(x)

        print(x.shape)
        x = nn.conv2d(x, 192, nonlinearity=leakyReLu, init=init, counters=counter)
        print(x.shape)
        x = nn.conv2d(x, 192, nonlinearity=leakyReLu, init=init, counters=counter)
        # Different strides needed to produce compatible shapes, [5,2] in DeepSeg, [5,2] in this code
        print(x.shape)
        x = nn.conv2d(
            x, 192, stride=[5, 2], nonlinearity=leakyReLu, init=init, counters=counter
        )

        print(x.shape)
        x = keras.layers.Dropout(0.5)(x)

        print(x.shape)
        x = nn.conv2d(
            x, 192, pad="VALID", nonlinearity=leakyReLu, init=init, counters=counter
        )
        print(x.shape)
        x = nn.nin(x, 192, counters=counter, nonlinearity=leakyReLu, init=init)
        print(x.shape)
        x = nn.nin(x, 192, counters=counter, nonlinearity=leakyReLu, init=init)
        print(x.shape)
        # Different pool size needed to produce compatible shapes, [6,6] in DeepSeg, [8,6] in this code
        x = keras.layers.MaxPooling2D(pool_size=(8, 6), strides=1)(x)
        print(x.shape)
        x = tf.squeeze(x, [1, 2])

        intermediate_layer = x

        logits = nn.dense(
            x, category, nonlinearity=None, init=init, counters=counter, init_scale=0.1
        )
        print("logits:", logits)

        return logits, intermediate_layer
