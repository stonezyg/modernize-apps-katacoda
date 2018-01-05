# Creating the model

Our catalog microservice will expose a Catalog endpoint that returns products so you will use a Java Interface to represent the contract that other services can use to interact with this service.

Let's create the interface called `Product.java` by first creating an empty file by clicking on ``src/main/java/com/redhat/coolstore/model/Product.java``{{open}}

Then add the following code to the `Product.java`.

<pre class="file" data-filename="src/main/java/com/redhat/coolstore/model/Product.java" data-target="replace">
package com.redhat.coolstore.model;

import java.io.Serializable;

public class Product implements Serializable {

	private static final long serialVersionUID = -7304814269819778382L;

	private String itemId;
	private String name;
	private String desc;
	private double price;
	private int quantity;

	public Product() {

	}

	public Product(String itemId, String name, String desc, double price) {
		super();
		this.itemId = itemId;
		this.name = name;
		this.desc = desc;
		this.price = price;
	}
	public String getItemId() {
		return itemId;
	}
	public void setItemId(String itemId) {
		this.itemId = itemId;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getDesc() {
		return desc;
	}
	public void setDesc(String desc) {
		this.desc = desc;
	}
	public double getPrice() {
		return price;
	}
	public void setPrice(double price) {
		this.price = price;
	}
    public int getQuantity() {
        return quantity;
    }
    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    @Override
	public String toString() {
		return "Product [itemId=" + itemId + ", name=" + name + ", desc="
				+ desc + ", price=" + price + ", quantity=" + quantity + "]";
	}



}

</pre>

The catalog service will also interact with the Inventory service so we need a interface for that as well.

Create the file ``src/main/java/com/redhat/coolstore/model/Inventory.java``{{open}}
 
And copy the following to it:

<pre class="file" data-filename="src/main/java/com/redhat/coolstore/model/Inventory.java" data-target="replace">
package com.redhat.coolstore.model;

import java.io.Serializable;

public class Inventory implements Serializable {

    private static final long serialVersionUID = 7131670354907280071L;

    private String itemId;
    private String location;
    private int quantity;
    private String link;

    public Inventory() {
    }

    public Inventory(String itemId, String location, int quantity, String link) {
        this.itemId = itemId;
        this.location = location;
        this.quantity = quantity;
        this.link = link;
    }

    public Inventory(String itemId, int quantity) {
        this.itemId = itemId;
        this.quantity = quantity;
    }

    public String getItemId() {
        return itemId;
    }

    public void setItemId(String itemId) {
        this.itemId = itemId;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public String getLink() {
        return link;
    }

    public void setLink(String link) {
        this.link = link;
    }

    @Override
    public String toString() {
        return "Inventory{" +
                "itemId='" + itemId + '\'' +
                ", location='" + location + '\'' +
                ", quantity=" + quantity +
                ", link='" + link + '\'' +
                '}';
    }
}
</pre>

# Creating a test. 

Before we create the database repository class to access the data it's good practice to create test cases for the different methods that we will use.

Click to open ``src/test/java/com/redhat/coolstore/service/ProductRepositoryTest.java``{{open}} to create the empty file and
then **Copy to Editor** to copy the below code into the file:

<pre class="file" data-filename="src/test/java/com/redhat/coolstore/service/ProductRepositoryTest.java" data-target="replace">
package com.redhat.coolstore.service;

import java.util.List;
import java.util.stream.Collectors;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

import static org.assertj.core.api.Assertions.assertThat;

import com.redhat.coolstore.model.Product;


@RunWith(SpringRunner.class)
@SpringBootTest()
public class ProductRepositoryTest {

    //TODO: Insert Catalog Component here

    //TODO: Insert test_readOne here

    //TODO: Insert test_readAll here

}

</pre>

Next, inject a handle to the future repository class which will provide access to the underlying data repository. It is
injected with Spring's `@Autowired` annotation which locates, instantiates, and injects runtime instances of classes automatically,
and manages their lifecycle (much like Java EE and it's CDI feature):

<pre class="file" data-filename="src/test/java/com/redhat/coolstore/service/ProductRepositoryTest.java" data-target="insert" data-marker="//TODO: Insert Catalog Component here">
    @Autowired
    ProductRepository repository;
</pre>

Now, implement two tests wich will fetch some products from the catalog and verify they are what you expect:

<pre class="file" data-filename="src/test/java/com/redhat/coolstore/service/ProductRepositoryTest.java" data-target="insert" data-marker="//TODO: Insert test_readOne here">
    @Test
    public void test_readOne() {
        Product product = repository.findById("444434");
        assertThat(product).isNotNull();
        assertThat(product.getName()).as("Verify product name").isEqualTo("Pebble Smart Watch");
        assertThat(product.getQuantity()).as("Quantity should be ZEOR").isEqualTo(0);
    }
</pre>

<pre class="file" data-filename="src/test/java/com/redhat/coolstore/service/ProductRepositoryTest.java" data-target="insert" data-marker="//TODO: Insert test_readAll here">
    @Test
    public void test_readAll() {
        List<Product> productList = repository.readAll();
        assertThat(productList).isNotNull();
        assertThat(productList).isNotEmpty();
        List<String> names = productList.stream().map(Product::getName).collect(Collectors.toList());
        assertThat(names).contains("Red Fedora","Forge Laptop Sticker","Oculus Rift");
    }
</pre>

# Implement the database repository

We are now ready to implement the database repository.  

Create the ``src/main/java/com/redhat/coolstore/service/ProductRepository.java``{{open}} by clicking the open link.

<pre class=file data-filename="src/main/java/com/redhat/coolstore/service/ProductRepository.java" data-target="replace">
package com.redhat.coolstore.service;

import java.util.List;

import com.redhat.coolstore.model.Product;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import sun.reflect.generics.reflectiveObjects.NotImplementedException;

@Repository
public class ProductRepository {

    //TODO: Autowire the jdbcTemplate here

    //TODO: Add row mapper here

    //TODO: Create a method for returning all products

    //TODO: Create a method for returning one product

}

</pre>

> NOTE: That the class is annotated with the @Repository annotation. This is a feature of Spring that makes it possible to avoid a lot of boiler plate code and only write the implementation details for this data repository. It also makes it very easy to switch to another data storage, like a NoSQL database.

Similar to above, inject a handle to a runtime JDBC template which will handle queries to the database:

<pre class="file" data-filename="src/main/java/com/redhat/coolstore/service/ProductRepository.java" data-target="insert" data-marker="//TODO: Autowire the jdbcTemplate here">
    @Autowired
    private JdbcTemplate jdbcTemplate;
</pre>

Now add logic to map rows coming out of the database to Java objects (in this case, `Product` objects):

<pre class="file" data-filename="src/main/java/com/redhat/coolstore/service/ProductRepository.java" data-target="insert" data-marker=" //TODO: Add row mapper here">
    private RowMapper<Product> rowMapper = (rs, rowNum) -> new Product(
            rs.getString("itemId"),
            rs.getString("name"),
            rs.getString("description"),
            rs.getDouble("price"));
</pre>

Now implement the two interfaces we'll expose to consumers of this service to get one or all products from the catalog:

<pre class="file" data-filename="src/main/java/com/redhat/coolstore/service/ProductRepository.java" data-target="insert" data-marker="//TODO: Create a method for returning all products">
    public List<Product> readAll() {
        return jdbcTemplate.query("SELECT * FROM catalog", rowMapper);
    }
</pre>

<pre class="file" data-filename="src/main/java/com/redhat/coolstore/service/ProductRepository.java" data-target="insert" data-marker="//TODO: Create a method for returning one product">
    public Product findById(String id) {
        return jdbcTemplate.queryForObject("SELECT * FROM catalog WHERE itemId = " + id, rowMapper);
    }
</pre>


Now we are ready to run the test to verify that everthing works.

``mvn verify``{{execute interrupt}}

The test should be successful and you should see **BUILD SUCCESS**, which means that we can read that our repository class works as as expected.

## Congratulations

You have now successfully executed the first step in this scenario. 

Now you've seen how to get started with Spring Boot development on Red Hat OpenShift Application Runtimes!

In next step of this scenario, we will add the logic to be able to read a list of fruits from the database.
