<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Articles get share/comment counts + featured_image storage variant
        Schema::table('articles', function (Blueprint $table) {
            if (! Schema::hasColumn('articles', 'comment_count')) {
                $table->unsignedInteger('comment_count')->default(0)->after('like_count');
            }
            if (! Schema::hasColumn('articles', 'share_count')) {
                $table->unsignedInteger('share_count')->default(0)->after('comment_count');
            }
        });

        // Categories get icon + is_active
        Schema::table('categories', function (Blueprint $table) {
            if (! Schema::hasColumn('categories', 'icon')) {
                $table->string('icon')->nullable()->after('name');
            }
            if (! Schema::hasColumn('categories', 'is_active')) {
                $table->boolean('is_active')->default(true)->after('sort_order');
            }
        });

        // New: shorts (video reels linked to articles or standalone)
        if (! Schema::hasTable('shorts')) {
            Schema::create('shorts', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('remote_id')->nullable()->unique();
                $table->foreignId('article_id')->nullable()->constrained('articles')->nullOnDelete();
                $table->string('title');
                $table->text('caption')->nullable();
                $table->string('source', 20)->default('cloudinary'); // cloudinary | youtube
                $table->string('video_id'); // Cloudinary public_id OR YouTube id
                $table->string('thumbnail')->nullable();
                $table->unsignedInteger('duration_seconds')->nullable();
                $table->boolean('is_sponsored')->default(false);
                $table->string('sponsor_label')->nullable();
                $table->boolean('is_published')->default(true);
                $table->unsignedBigInteger('view_count')->default(0);
                $table->timestamps();
                $table->index(['is_published', 'created_at']);
            });
        }

        // New: breaking_news ticker items
        if (! Schema::hasTable('breaking_news')) {
            Schema::create('breaking_news', function (Blueprint $table) {
                $table->id();
                $table->string('headline');
                $table->string('link_url')->nullable();
                $table->boolean('is_active')->default(true);
                $table->timestamp('expires_at')->nullable();
                $table->timestamps();
            });
        }

        // New: staff (news editors, reporters, presenters)
        if (! Schema::hasTable('staff')) {
            Schema::create('staff', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('remote_id')->nullable()->unique();
                $table->string('name');
                $table->string('phone')->nullable();
                $table->string('email')->nullable();
                $table->string('role')->nullable(); // reporter, editor, presenter, admin
                $table->string('photo')->nullable();
                $table->text('bio')->nullable();
                $table->boolean('is_visible')->default(true);
                $table->boolean('is_active')->default(true);
                $table->timestamps();
            });
        }

        // New: programmes (TV shows list, distinct from schedule slots)
        if (! Schema::hasTable('programmes')) {
            Schema::create('programmes', function (Blueprint $table) {
                $table->id();
                $table->unsignedBigInteger('remote_id')->nullable()->unique();
                $table->string('title');
                $table->string('slug')->unique();
                $table->text('description')->nullable();
                $table->string('thumbnail')->nullable();
                $table->string('category', 40)->default('General');
                $table->boolean('is_active')->default(true);
                $table->timestamps();
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('programmes');
        Schema::dropIfExists('staff');
        Schema::dropIfExists('breaking_news');
        Schema::dropIfExists('shorts');

        Schema::table('categories', function (Blueprint $table) {
            $table->dropColumn(['icon', 'is_active']);
        });
        Schema::table('articles', function (Blueprint $table) {
            $table->dropColumn(['comment_count', 'share_count']);
        });
    }
};
