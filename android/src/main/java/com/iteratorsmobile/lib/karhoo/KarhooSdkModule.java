package com.iteratorsmobile.lib.karhoo;

import android.content.Context;
import androidx.annotation.NonNull;
import com.braintreepayments.api.DropInClient;
import com.braintreepayments.api.DropInListener;
import com.braintreepayments.api.DropInRequest;
import com.braintreepayments.api.DropInResult;
import com.braintreepayments.api.ThreeDSecureRequest;
import com.braintreepayments.api.UserCanceledException;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.karhoo.sdk.analytics.AnalyticProvider;
import com.karhoo.sdk.api.KarhooApi;
import com.karhoo.sdk.api.KarhooEnvironment;
import com.karhoo.sdk.api.KarhooSDKConfiguration;
import com.karhoo.sdk.api.model.AuthenticationMethod;
import com.karhoo.sdk.api.model.BookingFee;
import com.karhoo.sdk.api.model.BookingFeePrice;
import com.karhoo.sdk.api.model.BraintreeSDKToken;
import com.karhoo.sdk.api.model.CancellationReason;
import com.karhoo.sdk.api.model.TripInfo;
import com.karhoo.sdk.api.network.request.Luggage;
import com.karhoo.sdk.api.network.request.PassengerDetails;
import com.karhoo.sdk.api.network.request.Passengers;
import com.karhoo.sdk.api.network.request.SDKInitRequest;
import com.karhoo.sdk.api.network.request.TripBooking;
import com.karhoo.sdk.api.network.request.TripCancellation;
import com.karhoo.sdk.api.network.response.Resource;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import kotlin.Unit;
import kotlin.coroutines.Continuation;
import kotlin.jvm.functions.Function0;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;

public class KarhooSdkModule extends ReactContextBaseJavaModule implements DropInListener {
    protected static final String PAYMENT_NONCE_CANCELLED = "PAYMENT_NONCE_CANCELLED";
    protected static final String PAYMENT_NONCE_FAILED = "PAYMENT_NONCE_FAILED";
    protected static final String BOOKING_FAILED = "BOOKING_FAILED";
    protected static final String TRIP_CANCEL_FAILED = "TRIP_CANCEL_FAILED";
    protected static final String CANCELLATION_FEE_FAILED = "CANCELLATION_FEE_FAILED";

    private final ReactApplicationContext reactContext;

    private Promise paymentNoncePromise;
    private String paymentNonceCorrelationId;

    public KarhooSdkModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @NonNull
    @Override
    public String getName() {
        return "KarhooSdk";
    }

    @Override
    public void onDropInSuccess(@NonNull DropInResult result) {
        WritableMap response = Arguments.createMap();
        response.putString("correlationId", this.paymentNonceCorrelationId);
        try {
            String paymentMethodNonce = Objects.requireNonNull(result.getPaymentMethodNonce(), "Received empty payment nonce.").getString();
            response.putString("nonce", paymentMethodNonce);
            this.paymentNoncePromise.resolve(response);
        } catch (NullPointerException exception) {
            response.putString("error", exception.getMessage());
            this.paymentNoncePromise.reject(PAYMENT_NONCE_FAILED, exception.getMessage());
        }
    }

    @Override
    public void onDropInFailure(@NonNull Exception error) {
        WritableMap response = Arguments.createMap();
        response.putString("correlationId", this.paymentNonceCorrelationId);
        if (error instanceof UserCanceledException) {
            this.paymentNoncePromise.reject(PAYMENT_NONCE_CANCELLED, response);
        } else {
            response.putString("error", error.getMessage());
            this.paymentNoncePromise.reject(PAYMENT_NONCE_FAILED, response);
        }
    }

    private WritableMap getKarhooErrorResponse(Resource.Failure karhooFailure) {
        WritableMap errorResponse = Arguments.createMap();
        errorResponse.putString("error", karhooFailure.getError().getUserFriendlyMessage());
        errorResponse.putString("correlationId", karhooFailure.getCorrelationId());
        return errorResponse;
    }

    private WritableMap getSdkErrorResponse(Exception error) {
        WritableMap errorResponse = Arguments.createMap();
        errorResponse.putString("error", error.getMessage());
        errorResponse.putString("correlationId", null);
        return errorResponse;
    }

    @ReactMethod
    public void initialize(final String identifier, final String referer, final String organisationId, final boolean isProduction) {
        KarhooApi.INSTANCE.setConfiguration(new KarhooSDKConfiguration() {
            @androidx.annotation.Nullable
            @Override
            public Object requireSDKAuthentication(@NonNull Function0<Unit> function0, @NonNull Continuation<? super Unit> continuation) {
                return null;
            }

            @NotNull
            @Override
            public KarhooEnvironment environment() {
                return isProduction ? new KarhooEnvironment.Production() : new KarhooEnvironment.Sandbox();
            }

            @NotNull
            @Override
            public Context context() {
                return Objects.requireNonNull(getCurrentActivity());
            }

            @NotNull
            @Override
            public AuthenticationMethod authenticationMethod() {
                return new AuthenticationMethod.Guest(identifier, referer, organisationId);
            }

            @Nullable
            @Override
            public AnalyticProvider analyticsProvider() {
                return null;
            }
        });
    }

    @ReactMethod
    public void getPaymentNonce(final String organisationId, final ReadableMap paymentData, final Promise promise) {
        try {
            this.paymentNoncePromise = promise;
            SDKInitRequest sdkInitRequest = new SDKInitRequest(organisationId, Objects.requireNonNull(paymentData.getString("currency")));
            KarhooApi.INSTANCE.getPaymentsService().initialisePaymentSDK(sdkInitRequest).execute(
                    resource -> {
                        if (resource instanceof Resource.Success) {
                            this.paymentNonceCorrelationId = ((Resource.Success<? extends BraintreeSDKToken>) resource).getCorrelationId();
                            String token = ((Resource.Success<? extends BraintreeSDKToken>) resource).getData().getToken();

                            ThreeDSecureRequest threeDSecureRequest = new ThreeDSecureRequest();
                            threeDSecureRequest.setAmount(paymentData.getString("amount"));
                            threeDSecureRequest.setVersionRequested(ThreeDSecureRequest.VERSION_2);

                            DropInRequest dropInRequest = new DropInRequest();
                            dropInRequest.setThreeDSecureRequest(threeDSecureRequest);

                            DropInClient dropInClient = new DropInClient(reactContext, token, dropInRequest);
                            dropInClient.setListener(this);
                            dropInClient.launchDropIn(dropInRequest);
                        } else {
                            this.paymentNoncePromise.reject(PAYMENT_NONCE_FAILED, getKarhooErrorResponse((Resource.Failure<? extends BraintreeSDKToken>) resource));

                            this.paymentNoncePromise = null;
                            this.paymentNonceCorrelationId = null;
                        }
                        return Unit.INSTANCE;
                    }
            );
        } catch (Exception error) {
            this.paymentNoncePromise.reject(PAYMENT_NONCE_FAILED, getSdkErrorResponse(error));

            this.paymentNoncePromise = null;
            this.paymentNonceCorrelationId = null;
        }
    }

    @ReactMethod
    public void bookTrip(ReadableMap passenger, String quoteId, String paymentNonce, final Promise promise) {
        try {
            List<PassengerDetails> passengersList = Collections.singletonList(new PassengerDetails(
                    passenger.getString("firstName"),
                    passenger.getString("lastName"),
                    passenger.getString("email"),
                    passenger.getString("mobileNumber"),
                    passenger.getString("locale")
            ));
            Luggage luggage = new Luggage(0);
            Passengers passengers = new Passengers(0, passengersList, luggage);
            TripBooking tripBooking = new TripBooking(null, null, null, null, passengers, null, paymentNonce, null, null, null, null, 0, quoteId);

            KarhooApi.INSTANCE.getTripService().book(tripBooking).execute(
                    resource -> {
                        if (resource instanceof Resource.Success) {
                            WritableMap successResponse = Arguments.createMap();
                            successResponse.putString("tripId", ((Resource.Success<TripInfo>) resource).getData().getTripId());
                            successResponse.putString("followCode", ((Resource.Success<TripInfo>) resource).getData().getFollowCode());
                            successResponse.putString("correlationId", ((Resource.Success<TripInfo>) resource).getCorrelationId());
                            promise.resolve(successResponse);
                        } else {
                            promise.reject(BOOKING_FAILED, getKarhooErrorResponse((Resource.Failure<TripInfo>) resource));
                        }
                        return Unit.INSTANCE;
                    }
            );
        } catch (Exception error) {
            promise.reject(BOOKING_FAILED, getSdkErrorResponse(error));
        }
    }

    @ReactMethod
    public void cancellationFee(String followCode, final Promise promise) {
        try {
            KarhooApi.INSTANCE.getTripService().cancellationFee(followCode).execute(
                    resource -> {
                        if (resource instanceof Resource.Success) {
                            WritableMap successResponse = Arguments.createMap();
                            successResponse.putBoolean("cancellationFee", ((Resource.Success<BookingFee>) resource).getData().getCancellationFee());
                            successResponse.putString("correlationId", ((Resource.Success<BookingFee>) resource).getCorrelationId());

                            BookingFeePrice bookingFeePrice = ((Resource.Success<BookingFee>) resource).getData().getFee();
                            if (bookingFeePrice != null) {
                                WritableMap bookingFeePriceMap = Arguments.createMap();
                                bookingFeePriceMap.putString("currency", bookingFeePrice.getCurrency());
                                bookingFeePriceMap.putString("type", bookingFeePrice.getType());
                                bookingFeePriceMap.putDouble("value", bookingFeePrice.getValue());

                                successResponse.putMap("fee", bookingFeePriceMap);
                            }

                            promise.resolve(successResponse);
                        } else {
                            promise.reject(CANCELLATION_FEE_FAILED, getKarhooErrorResponse((Resource.Failure<BookingFee>) resource));
                        }
                        return Unit.INSTANCE;
                    }
            );
        } catch (Exception error) {
            promise.reject(CANCELLATION_FEE_FAILED, getSdkErrorResponse(error));
        }
    }

    @ReactMethod
    public void cancelTrip(String followCode, final Promise promise) {
        try {
            TripCancellation tripCancellation = new TripCancellation(followCode, CancellationReason.OTHER_USER_REASON, null);
            KarhooApi.INSTANCE.getTripService().cancel(tripCancellation).execute(
                    resource -> {
                        if (resource instanceof Resource.Success) {
                            WritableMap successResponse = Arguments.createMap();
                            successResponse.putBoolean("tripCancelled", true);
                            successResponse.putString("correlationId", ((Resource.Success<? extends Void>) resource).getCorrelationId());
                            promise.resolve(successResponse);
                        } else {
                            promise.reject(TRIP_CANCEL_FAILED, getKarhooErrorResponse((Resource.Failure<? extends Void>) resource));
                        }
                        return Unit.INSTANCE;
                    }
            );
        } catch (Exception error) {
            promise.reject(TRIP_CANCEL_FAILED, getSdkErrorResponse(error));
        }
    } 
}