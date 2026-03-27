
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.stereotype.Controller;
import org.springframework.web.socket.config.annotation.*;
import org.springframework.beans.factory.annotation.Autowired;
import jakarta.persistence.*;
import java.util.concurrent.atomic.AtomicInteger;

@SpringBootApplication
@EnableWebSocketMessageBroker
public class DistClockApplication implements WebSocketMessageBrokerConfigurer {
    public static void main(String[] args) {
        SpringApplication.run(DistClockApplication.class, args);
    }

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws").setAllowedOriginPatterns("*").withSockJS();
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry config) {
        config.enableSimpleBroker("/topic");
        config.setApplicationDestinationPrefixes("/app");
    }
}

@Entity
class Ticket {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    public Long id;
    public int serverId;
    public int seatId;
    public int bookingClock;
}

@Controller
class TicketController {
    @Autowired
    private TicketRepository repo;
    private final AtomicInteger lamportClock = new AtomicInteger(0);

    @MessageMapping("/book")
    @SendTo("/topic/updates")
    public BookingMessage handleBooking(BookingMessage msg) {
        int local = lamportClock.incrementAndGet();
        int finalClock = Math.max(local, msg.clock) + 1;
        lamportClock.set(finalClock);

        try {
            Ticket t = new Ticket();
            t.serverId = msg.serverId;
            t.seatId = msg.seatId;
            t.bookingClock = finalClock;
            repo.save(t);
            msg.status = "SUCCESS";
        } catch (Exception e) {
            msg.status = "ERROR";
        }

        msg.clock = finalClock;
        return msg;
    }
}

class BookingMessage {
    public int serverId, seatId, clock, clientId;
    public String status;
}