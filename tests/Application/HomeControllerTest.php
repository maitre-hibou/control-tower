<?php

namespace App\Tests\Application;

use Symfony\Bundle\FrameworkBundle\Test\WebTestCase;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

final class HomeControllerTest extends WebTestCase
{
    public function testHomepageDisplaysSuccessfully(): void
    {
        $client = self::createClient();

        $crawler = $client->request(Request::METHOD_GET, '/');

        $this->assertEquals(Response::HTTP_OK, $client->getResponse()->getStatusCode());
        $this->assertGreaterThan(0, $crawler->filter('h1:contains("Control Tower")')->count());
    }
}
