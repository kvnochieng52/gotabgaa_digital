<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProgramResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->slug,
            'title' => $this->title,
            'description' => $this->description,
            'host' => $this->host,
            'type' => $this->type,
            'day' => $this->day,
            'start' => substr($this->start_time, 0, 5),
            'end' => substr($this->end_time, 0, 5),
            'image' => $this->image && str_starts_with($this->image, '#')
                ? $this->image
                : ($this->image ? url('storage/'.$this->image) : '#E63946|#FF7A1A'),
        ];
    }
}
